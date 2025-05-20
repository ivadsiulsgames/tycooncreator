local HttpService = game:GetService("HttpService")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")
local Debris = game:GetService("Debris")

local Dropper = {}
Dropper.__index = Dropper

local function createCashPart(_, dropperPart, cashVal)
	local newPart = dropperPart:Clone()

	newPart.Position = dropperPart.Position - Vector3.new(0, (dropperPart.Size.Y / 2) + 1, 0)
	newPart.Anchored = false

	newPart.Name = "cashPart"

	newPart:AddTag("CashPart")
	newPart:SetAttribute("Id", HttpService:GenerateGUID(false))
	newPart:SetAttribute("CashValue", cashVal)
	newPart:SetAttribute("Owner", dropperPart.Parent:GetAttribute("Owner"))

	Debris:AddItem(newPart, 90)

	newPart.Parent = workspace
end

local function startLoop(model, maid)
	if not model:FindFirstAncestor("Workspace") then
		return
	end
	if model:GetAttribute("Looping") == true then
		return
	end

	model:SetAttribute("Looping", true)

	local dropperPart = model.DropperPart

	local rate

	maid:GiveTask(RxAttributeUtils.observeAttribute(model, "Rate", 3):Subscribe(function(value)
		rate = value
	end))

	local cashVal

	maid:GiveTask(RxAttributeUtils.observeAttribute(model, "CashValue", 3):Subscribe(function(value)
		cashVal = value
	end))

	model:SetAttribute("Enabled", true)

	maid:GiveTask(task.spawn(function()
		while true do
			createCashPart(maid, dropperPart, cashVal)
			task.wait(rate)
		end
	end))
end

function Dropper.new(model)
	local maid = Maid.new()

	startLoop(model, maid)

	model:GetPropertyChangedSignal("Parent"):Connect(function()
		startLoop(model, maid)
	end)

	return setmetatable({
		_maid = maid,
	}, Dropper)
end

function Dropper:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("Dropper", Dropper)

return binder
