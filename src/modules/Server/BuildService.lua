--[=[
	@class BuildService
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

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
    self.PlaceBlockRemote.OnServerEvent:Connect(function(_, blockName)
		local block = ReplicatedStorage.Assets.Blocks[blockName]

		block:Clone().Parent = workspace
    end)
end

return BuildService