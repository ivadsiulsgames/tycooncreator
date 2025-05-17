local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Blend = require("Blend")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")

local Conveyor = {}
Conveyor.__index = Conveyor

local function setVelocity(part, maid)
	maid:GiveTask(Blend.Spring(RxAttributeUtils.observeAttribute(part, "Velocity", 5)):Subscribe(function(value)
		part.AssemblyLinearVelocity = part.CFrame.LookVector * value
	end))
end

function Conveyor.new(part)
	local maid = Maid.new()

	setVelocity(part, maid)

	return setmetatable({
		_maid = maid,
	}, Conveyor)
end

function Conveyor:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("Conveyor", Conveyor)

return binder
