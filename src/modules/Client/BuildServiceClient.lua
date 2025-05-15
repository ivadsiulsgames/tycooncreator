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
    self.InputServiceClient = self._serviceBag:GetService(require("InputServiceClient"))

    self.PlaceBlockRemote = ReplicatedStorage.Remotes.PlaceBlock

    self.inPlacement = false
end

function BuildServiceClient:StartPlacementMode(blockName: string)
    if self.inPlacement == true then return end
    self.inPlacement = true

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

    local blockRot = Vector3.new(0, 0, 0)

    RunService:BindToRenderStep("Building", Enum.RenderPriority.Input.Value - 1, function(delta)
        if not mouse.Hit or not mouse.Target then return end

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
        end
    end)

    local rotateConn
    
    rotateConn = self.InputServiceClient:BindToSignal("RotateBuild", function(_, _)
        blockRot += Vector3.new(0, 90, 0)
    end)

    local buildConn

    buildConn = self.InputServiceClient:BindToSignal("Build", function(_, _)
        self:PlaceBlock(blockName, mouse.Hit.Position, mouse.Target, blockRot)

        previewBlock:Destroy()

        RunService:UnbindFromRenderStep("Building")

        self.inPlacement = false
        mouse.TargetFilter = nil

        rotateConn:Disconnect()
        buildConn:Disconnect() 
    end)
end

function BuildServiceClient:PlaceBlock(blockName: string, hitPos: Vector3, mouseTarget: Instance, yRot: Vector3)
    self.PlaceBlockRemote:FireServer(blockName, hitPos, mouseTarget, yRot)
end


return BuildServiceClient