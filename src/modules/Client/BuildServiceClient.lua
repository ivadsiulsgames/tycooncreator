--[=[
	@class BuildServiceClient
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

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
    self.PlaceBlockRemote = ReplicatedStorage.Remotes.PlaceBlock
end

function BuildServiceClient:StartPlacementMode(blockName: string)
    local block = ReplicatedStorage.Assets.Blocks[blockName]

    local previewBlock: Model = block:Clone()
    previewBlock.Name = "Preview"

    previewBlock.Parent = workspace

    for _, part in previewBlock:GetDescendants() do
        if part:IsA("BasePart") and part ~= previewBlock.PrimaryPart then
            part.Transparency = 0.6
            part.Color = Color3.fromRGB(0, 255, 0)
            
            part.CanCollide = false
        end
    end

    mouse.TargetFilter = previewBlock

    RunService:BindToRenderStep("Building", Enum.RenderPriority.Input.Value-1, function(delta)
        if not mouse.Hit or not mouse.Target then return end

        local blockPart = previewBlock.PrimaryPart
        local cframe = CalculateGridCF(mouse.Hit.Position, Vector3.new(0, 1, 0), mouse.Target, false, 0)

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
        end
    end)
end

function BuildServiceClient:PlaceBlock(blockName: string)
    self.PlaceBlockRemote:FireServer(blockName)
end


return BuildServiceClient