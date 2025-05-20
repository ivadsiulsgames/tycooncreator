local CollectionService = game:GetService("CollectionService")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local CashPart = {}
CashPart.__index = CashPart

local function onTouched(part, otherPart, _serviceBag: ServiceBag.ServiceBag)
	if not CollectionService:HasTag(otherPart, "CashPart") then
		return
	end

	if
		otherPart:GetAttribute("Owner") == part:GetAttribute("Owner")
		and otherPart:GetAttribute("Id") < part:GetAttribute("Id")
	then
		part:SetAttribute("Merging", true)
		part:SetAttribute("CashValue", part:GetAttribute("CashValue") + otherPart:GetAttribute("CashValue"))
		otherPart:Destroy()
	end
end

function CashPart.new(part, _serviceBag: ServiceBag.ServiceBag)
	local maid = Maid.new()

	part.Touched:Connect(function(otherPart)
		onTouched(part, otherPart, _serviceBag)
	end)

	return setmetatable({
		_maid = maid,
	}, CashPart)
end

function CashPart:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("CashPart", CashPart)

return binder
