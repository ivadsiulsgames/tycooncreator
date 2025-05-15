--[=[
	@class DataService
]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local DataStore = require("DataStore")

local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

local dataStoreName = "game"

if RunService:IsStudio() then
    dataStoreName = "studio"
end

local DataService = {}
DataService.ServiceName = "DataService"

function DataService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

    self._maid = Maid.new()

	-- External
    self.DataStoreService = self._serviceBag:GetService(require("DataStoreService"))
    self.PlayerDataStoreService = self._serviceBag:GetService(require("PlayerDataStoreService"))

	-- Internal
    self.dataStore = DataStore.new(self.DataStoreService:GetDataStore(`{dataStoreName}`), `{dataStoreName}-store`)
end

function DataService:GetPlayerDataFolder(player: Player)
    local playerData = assert(player:FindFirstChild("PlayerData"), "PlayerData folder not found.")
    
    return playerData
end

function DataService:Start()
    local PlayerDataStoreService = self.PlayerDataStoreService

    local function handlePlayer(player: Player)
        local maid = Maid.new()

        local cashValue = Instance.new("IntValue")
        cashValue.Name = "Cash"
        cashValue.Value = 0
        cashValue.Parent = player

        maid:GivePromise(PlayerDataStoreService:PromiseDataStore(player)):Then(function(dataStore)
            maid:GivePromise(dataStore:Load("cash", 0))
                :Then(function(cash)
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