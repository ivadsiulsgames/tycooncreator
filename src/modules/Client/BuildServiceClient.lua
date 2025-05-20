--[=[
	@class BuildServiceClient
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local AccelTween = require("AccelTween")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

local SoundUtils = require("SoundUtils")
local Sounds = require("Sounds")

local CalculateGridCF = require("CalculateGridCF")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local BuildServiceClient = {}
BuildServiceClient.ServiceName = "BuildServiceClient"

function BuildServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
	self.InputServiceClient = self._serviceBag:GetService(require("InputServiceClient"))

	self.PlaceBlockRemote = ReplicatedStorage.Remotes.PlaceBlock
	self.DeleteBlockRemote = ReplicatedStorage.Remotes.DeleteBlock

	self.inPlacement = false
	self.inDeleting = false

	self.placingBlockName = nil

	self.previewBlock = nil

	self.buildConn = nil
	self.rotateConn = nil

	self.deleteConn = nil

	self.PlacementStopped = Signal.new() :: Signal.Signal<any>
end

function BuildServiceClient:GetPlacingBlockName()
	return self.placingBlockName
end

function BuildServiceClient:IsPlacing(): boolean
	return self.inPlacement
end

function BuildServiceClient:IsDeleting(): boolean
	return self.inDeleting
end

function BuildServiceClient:GetPlacementStoppedSignal()
	return self.PlacementStopped
end

function BuildServiceClient:StartPlacementMode(blockName: string)
	if self.inPlacement == true or self.inDeleting == true then
		return
	end
	self.inPlacement = true

	local block = ReplicatedStorage.Assets.Blocks[blockName]
	local canPlace = true

	self.previewBlock = block:Clone()
	self.placingBlockName = self.previewBlock.Name

	local previewBlock = self.previewBlock
	previewBlock.Name = "Preview"

	previewBlock.Parent = workspace.Blocks

	for _, part in previewBlock:GetDescendants() do
		if part:IsA("BasePart") and part ~= previewBlock.PrimaryPart and not part:FindFirstAncestor("Hitboxes") then
			part.Transparency = 0.6
			part.Color = Color3.fromRGB(0, 255, 0)

			part.CanCollide = false
		end
	end

	mouse.TargetFilter = previewBlock

	local blockRot = Vector3.new(0, 0, 0)

	RunService:BindToRenderStep("Building", Enum.RenderPriority.Input.Value - 1, function(delta)
		if not mouse.Hit or not mouse.Target then
			return
		end

		local blockPart = previewBlock.PrimaryPart
		local gridCframe = CalculateGridCF(mouse.Hit.Position, Vector3.new(0, 1, 0), mouse.Target, false, 0)
		local cframe = gridCframe * CFrame.Angles(math.rad(blockRot.X), math.rad(blockRot.Y), math.rad(blockRot.Z))

		previewBlock:PivotTo(blockPart.CFrame:Lerp(cframe, 0.75 * 60 * delta))

		if mouse.Target:HasTag("Buildable") then
			for _, part in previewBlock:GetDescendants() do
				if part:IsA("BasePart") and part ~= previewBlock.PrimaryPart then
					part.Color = Color3.fromRGB(0, 255, 0)
				end
			end
		else
			for _, part in previewBlock:GetDescendants() do
				if part:IsA("BasePart") and part ~= previewBlock.PrimaryPart then
					part.Color = Color3.fromRGB(255, 0, 0)
				end
			end
			canPlace = false
		end

		local partsInside = 0

		local HitboxParts = previewBlock:FindFirstChild("Hitboxes"):GetDescendants()

		if not HitboxParts then
			return
		end

		for _, hitbox in HitboxParts do
			for _, part in workspace:GetPartsInPart(hitbox) do
				if
					not part:IsDescendantOf(previewBlock)
					and not part:HasTag("Buildable")
					and not Players:GetPlayerFromCharacter(part.Parent)
					and not Players:GetPlayerFromCharacter(part.Parent.Parent)
					and not part:HasTag("CashPart")
				then
					partsInside += 1
				end
			end
		end

		if partsInside > 0 then
			for _, part in previewBlock:GetDescendants() do
				if part:IsA("BasePart") and part ~= previewBlock.PrimaryPart then
					part.Color = Color3.fromRGB(255, 0, 0)
				end
			end
			canPlace = false
		else
			canPlace = true
		end
	end)

	self.rotateConn = self.InputServiceClient:BindToSignal("RotateBuild", function(_, _)
		blockRot += Vector3.new(0, 90, 0)
	end)

	self.buildConn = self.InputServiceClient:BindToSignal("BuildOrDelete", function(_, _)
		self:PlaceBlock(blockName, mouse.Hit.Position, mouse.Target, blockRot)

		previewBlock:Destroy()

		RunService:UnbindFromRenderStep("Building")

		self.inPlacement = false
		self.placingBlockName = nil

		mouse.TargetFilter = nil

		if canPlace == false then
			SoundUtils.playFromId(Sounds.PlacementError)
		end

		self.PlacementStopped:Fire()

		self.rotateConn:Disconnect()
		self.buildConn:Disconnect()
	end)
end

function BuildServiceClient:StopPlacementMode()
	if not self.inPlacement then
		return
	end

	self.previewBlock:Destroy()

	RunService:UnbindFromRenderStep("Building")

	self.inPlacement = false
	self.placingBlockName = nil

	mouse.TargetFilter = nil

	self.PlacementStopped:Fire()

	self.rotateConn:Disconnect()
	self.buildConn:Disconnect()
end

function BuildServiceClient:PlaceBlock(blockName: string, hitPos: Vector3, mouseTarget: Instance, yRot: Vector3)
	self.PlaceBlockRemote:FireServer(blockName, hitPos, mouseTarget, yRot, Players.LocalPlayer)
end

function BuildServiceClient:StartDeleteMode()
	if self.inPlacement == true then
		self:StopPlacementMode()
	elseif self.inDeleting then
		return
	end
	self.inDeleting = true

	local deletingHighlight = Instance.new("Highlight")
	deletingHighlight.FillTransparency = 1
	deletingHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)

	deletingHighlight.Adornee = nil

	deletingHighlight.Parent = workspace.CurrentCamera

	local selectedBlock = nil

	RunService:BindToRenderStep("Deleting", Enum.RenderPriority.Input.Value - 1, function()
		if not mouse.Target then
			return
		end

		local block = mouse.Target.Parent

		if not block:HasTag("Block") then
			block = mouse.Target.Parent.Parent

			if not block:HasTag("Block") then
				deletingHighlight.Adornee = nil
				return
			else
				mouse.TargetFilter = mouse.Target.Parent
			end
		end

		deletingHighlight.Adornee = block
		selectedBlock = block
	end)

	self.deleteConn = self.InputServiceClient:BindToSignal("BuildOrDelete", function(_, _)
		task.spawn(function()
			self:DeleteBlock(selectedBlock)
		end)

		RunService:UnbindFromRenderStep("Deleting")
		deletingHighlight:Destroy()

		SoundUtils.playFromId(Sounds.DeleteBlock)

		self.inDeleting = false

		self.deleteConn:Disconnect()
	end)
end

function BuildServiceClient:DeleteBlock(block: Model)
	if not block then
		return
	end

	local tween = AccelTween.new()
	tween.t = 1

	for _, part in block:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("Texture") then
			if part:IsA("BasePart") then
				part.CanCollide = false
			end

			if part == block.PrimaryPart or part:IsDescendantOf(block:FindFirstChild("Hitboxes")) then
				continue
			end

			local conn = RunService.PreRender:Connect(function()
				part.Transparency = tween.p
			end)

			task.delay(tween.rtime, function()
				conn:Disconnect()
			end)
		end
	end

	task.wait(tween.rtime)

	self.DeleteBlockRemote:FireServer(block)
end

function BuildServiceClient:Start()
	self.InputServiceClient:BindToSignal("DeleteMode", function(_, _)
		self:StartDeleteMode()
	end)
end

return BuildServiceClient
