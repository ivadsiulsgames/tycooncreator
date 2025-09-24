local require = require(script.Parent.loader).load(parent)

local AttributeValue = require("AttributeValue")
local Binder = require("Binder")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")
local RxInstanceUtils = require("RxInstanceUtils")
local ValueObject = require("ValueObject")
local Debris = game:GetService("Debris")
local BaseObject = require("BaseObject")
local Rx = require("Rx")
local RxBrioUtils = require("RxBrioUtils")

local CashPart = require("CashPart")

local ServiceBag = require("ServiceBag")

local CASH_LIFETIME = 90

local Dropper = setmetatable({}, BaseObject)
Dropper.__index = Dropper

function Dropper.new(model, serviceBag: ServiceBag.ServiceBag)
	local self = setmetatable(BaseObject.new(model), Dropper)
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._cashPart = serviceBag:GetService(CashPart)

	self.Enabled = AttributeValue.new(self._obj, "Enabled", true)

	self.Owner = AttributeValue.new(self._obj, "Owner", 0)
	self.Cash = AttributeValue.new(self._obj, "Cash", 3)
	self.Rate = AttributeValue.new(self._obj, "Rate", 3)

	self.DropperPart = self._maid:Add(
		ValueObject.fromObservable(
			RxInstanceUtils.observeLastNamedChildBrio(self._obj, "BasePart", "DropperPart"):Pipe({
				RxBrioUtils.flattenToValueAndNil,
			})
		)
	)

	self._maid:Add(Rx.combineLatest({
		droppedTemplate = self.DropperPart:Observe(),
		_interval = self:_observeRewardInterval(),
	}):Subscribe(function(state)
		if not state.droppedTemplate then
			return
		end

		self:_promiseBoundCashPart(state.droppedTemplate):Then(function(boundCash)
			boundCash.Cash.Value = self.Cash.Value
			boundCash.Owner.Value = self.Owner.Value

			self._maid:Add(task.delay(CASH_LIFETIME, boundCash.Destroy, boundCash))
		end)
	end))

	return self
end

function Dropper:_promiseBoundCashPart(template)
	local droppedPart = template:Clone()
	droppedPart.Name = "cashPart"
	droppedPart.Position -= Vector3.new(0, (droppedPart.Size.Y / 2) + 1, 0)
	droppedPart.Anchored = false

	self._cashPart:Tag(droppedPart)

	droppedPart.Parent = workspace

	return self._cashPart:Promise(droppedPart)
end

function Dropper:_observeRewardInterval()
	return self.Enabled:Observe():Pipe({
		Rx.switchMap(function(enabled)
			if not enabled then
				return Rx.EMPTY
			end

			return self.Rate:Observe():Pipe({
				Rx.switchMap(function(rate)
					return Rx.interval(rate)
				end),
			})
		end),
	})
end

function Dropper:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

return Binder.new("Dropper", Dropper)
