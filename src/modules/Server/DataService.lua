--[=[
	@class DataService
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local DataService = {}
DataService.ServiceName = "DataService"

function DataService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	self._maid = Maid.new()

	-- External
	self.PlayerDataStoreService = self._serviceBag:GetService(require("PlayerDataStoreService"))

	-- Internal
end

function DataService:GetPlayerDataFolder(player: Player)
	local playerData = assert(player:FindFirstChild("PlayerData"), "PlayerData folder not found.")

	return playerData
end

function DataService:Start()
	local PlayerDataStoreService = self.PlayerDataStoreService

	local function handlePlayer(player: Player)
		local maid = Maid.new()

		local playerData = Instance.new("Folder")
		playerData.Name = "PlayerData"
		playerData.Parent = player

		local cashValue = Instance.new("IntValue")
		cashValue.Name = "Cash"
		cashValue.Value = 0
		cashValue.Parent = playerData

		maid:GivePromise(PlayerDataStoreService:PromiseDataStore(player)):Then(function(dataStore)
			maid:GivePromise(dataStore:Load("cash", 0)):Then(function(cash)
				cashValue.Value = cash
				maid:GiveTask(dataStore:StoreOnValueChange("cash", cashValue))
			end)
		end)

		self._maid[player] = maid
	end

	Players.PlayerAdded:Connect(handlePlayer)

	Players.PlayerRemoving:Connect(function(player)
		self._maid[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(handlePlayer, player)
	end
end

return DataService
