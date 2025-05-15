local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local Binder = require("Binder")
local Maid = require("Maid")
local AccelTween = require("AccelTween")
local RxAttributeUtils = require("RxAttributeUtils")
local Blend = require("Blend")

local arrowId = "rbxassetid://293296862"


local Conveyor = {}
Conveyor.__index = Conveyor

local function createTexture(part, maid)
	if not part:FindFirstAncestor("Workspace") then return end
	if part:FindFirstChildWhichIsA("Texture") then return end

	local texture = Instance.new("Texture")
	texture.Texture = arrowId
	texture.Face = Enum.NormalId.Top

	local xSize = part.Size.X

	texture.StudsPerTileU = xSize
	texture.StudsPerTileV = xSize

	local textureTween = AccelTween.new()
	textureTween.t = -part.Size.Z

	local velocity
	
	maid:GiveTask(Blend.Spring(RxAttributeUtils.observeAttribute(part, "Velocity", 5)):Subscribe(function(value)
		velocity = value
	end))

	maid:GiveTask(RunService.PreRender:Connect(function()
		texture.OffsetStudsV = textureTween.p
		textureTween.v = -velocity
	end))

	texture.Parent = part

	return texture
end

function Conveyor.new(part)
	local maid = Maid.new()

	
	createTexture(part, maid)

	part:GetPropertyChangedSignal("Parent"):Connect(function()
		createTexture(part, maid)
	end)

	return setmetatable({
		_maid = maid
	}, Conveyor)
end

function Conveyor:Destroy()
	self._maid:Destroy()
	setmetatable(self, nil)
end

local binder = Binder.new("Conveyor", Conveyor)
binder:Start() -- listens for new instances and connects events

return Conveyor