--[=[
	@class CommandsServiceClient
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local InputNames = require("InputNames")
local InputPlatforms = require("InputPlatforms")
local InputSettings = require("InputSettings")
local ServiceBag = require("ServiceBag")

local Remotes = ReplicatedStorage.Remotes

local CommandsServiceClient = {}
CommandsServiceClient.ServiceName = "CommandsServiceClient"

function CommandsServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal

	self:ConnectToDebugRemote()
end

function CommandsServiceClient:ConnectToDebugRemote()
	local DebugRemote = Remotes.DebugCommands

	DebugRemote.OnClientEvent:Connect(
		function(
			inputName: InputNames.InputName,
			inputPlatform: InputPlatforms.InputPlatform,
			newInput: Enum.UserInputType | Enum.KeyCode
		)
			InputSettings:ChangeInput(inputName, inputPlatform, newInput)
		end
	)
end

return CommandsServiceClient
