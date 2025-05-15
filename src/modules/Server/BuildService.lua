--[=[
	@class BuildService
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local CalculateGridCF = require("CalculateGridCF")

local BuildService = {}
BuildService.ServiceName = "BuildService"

function BuildService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal
    self.PlaceBlockRemote = ReplicatedStorage.Remotes.PlaceBlock
end

function BuildService:Start()
    self.PlaceBlockRemote.OnServerEvent:Connect(function(_, blockName: string, hitPos: Vector3, mouseTarget: Instance, blockRot: Vector3)
		if not mouseTarget or not hitPos or not mouseTarget:HasTag("Buildable") or not blockRot then
			return
		end

		local block = ReplicatedStorage.Assets.Blocks[blockName]

		if not block then return end

		local blockClone = block:Clone()
		blockClone.Parent = workspace

		local gridCF = CalculateGridCF(hitPos, Vector3.new(0, 1, 0), mouseTarget, false, 0)

		local cframe = gridCF * CFrame.Angles(math.rad(blockRot.X), math.rad(blockRot.Y), math.rad(blockRot.Z))

		blockClone:PivotTo(cframe)
    end)
end

return BuildService