local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")


local SellPart = {}
SellPart.__index = SellPart

local cash = 0

local function onTouched(otherPart, _serviceBag: ServiceBag.ServiceBag)
	if CollectionService:HasTag(otherPart, "CashPart") then
		otherPart:Destroy()
		cash += otherPart:GetAttribute("CashValue")
		print(cash)
	end
end

function SellPart.new(part, _serviceBag: ServiceBag.ServiceBag)
	local maid = Maid.new()

	part.Touched:Connect(function(otherPart)
		onTouched(otherPart, _serviceBag)
	end)

	return setmetatable({
		_maid = maid
	}, SellPart)
end

function SellPart:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("SellPart", SellPart)
binder:Start() -- listens for new instances and connects events

return SellPart