local require = require(script.Parent.loader).load(script)

local HttpService = game:GetService("HttpService")

local AttributeValue = require("AttributeValue")
local BaseObject = require("BaseObject")
local Binder = require("Binder")
local Rx = require("Rx")
local ServiceBag = require("ServiceBag")

local CashPart = setmetatable({}, BaseObject)
CashPart.__index = CashPart

function CashPart.new(part: BasePart, _serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable(BaseObject.new(part), CashPart)

	self.Id = AttributeValue.new(self._obj, "Id", HttpService:GenerateGUID(false))
	self.Owner = AttributeValue.new(self._obj, "Owner", 0)
	self.Cash = AttributeValue.new(self._obj, "Cash", 0)

	self.Merging = AttributeValue.new(self._obj, "Merging", false)

	self._maid:Add(Rx.combineLatest({
		id = self.Id:Observe(),
		owner = self.Owner:Observe(),
		touched = Rx.fromSignal(self._obj.Touched),
	})
		:Pipe({
			Rx.where(function(state)
				local touchedId = state.touched:GetAttribute("Id")
				local touchedOwner = state.touched:GetAttribute("Owner")

				if not touchedId or not touchedOwner then
					return false
				end

				if not state.id or not state.owner then
					return false
				end

				return touchedOwner == state.owner and touchedId < state.id
			end),
		})
		:Subscribe(function(state)
			local touchedCash = state.touched:GetAttribute("Cash") or 0

			self.Merging.Value = true
			self.Cash.Value += touchedCash
			state.touched:Destroy()
		end))

	return self
end

function CashPart:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

return Binder.new("CashPart", CashPart)
