--[[
	@class ClientMain
]]
local loader = game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent) :: any

local serviceBag = require("ServiceBag").new()

serviceBag:GetService(require("GameServiceClient"))

serviceBag:Init()
serviceBag:Start()