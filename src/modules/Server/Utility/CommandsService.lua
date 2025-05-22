--[=[
	@class CommandsService
]=]

local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local require = require(script.Parent.loader).load(script)

local InputNames = require("InputNames")
local InputPlatforms = require("InputPlatforms")
local ServiceBag = require("ServiceBag")

local Remotes = ReplicatedStorage.Remotes

local CommandsService = {}
CommandsService.ServiceName = "CommandsService"

function CommandsService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self.CmdrService = self._serviceBag:GetService(require("CmdrService"))

	-- Internal
	self.CashService = self._serviceBag:GetService(require("CashService"))
end

function CommandsService:RegisterBanCommand()
	self.CmdrService:RegisterCommand({
		Name = "ban",
		Aliases = {},
		Description = "Bans a player from the game.",
		Group = "Admin",
		Args = {
			{
				Type = "string",
				Name = "username",
				Description = "The player to ban's username.",
			},
			{
				Type = "duration",
				Name = "duration",
				Description = "How long the player will be banned from.",
			},
			{
				Type = "string",
				Name = "displayReason",
				Description = "The reason the player will be shown.",
			},
			{
				Type = "string",
				Name = "privateReason",
				Description = " Internal messaging that will be returned when querying the user's ban history.",
			},
			{
				Type = "boolean",
				Name = "includeAlts",
				Description = "When true, Roblox attempts to ban alt accounts aswell.",
			},
		},
	}, function(_, playerToBanName, duration, displayReason, privateReason, includeAlts)
		Players:BanAsync({
			UserIds = { Players:GetUserIdFromNameAsync(playerToBanName) },
			ApplyToUniverse = true,
			Duration = duration,
			DisplayReason = displayReason,
			PrivateReason = privateReason,
			ExcludeAltAccounts = not includeAlts,
		})
	end)
end

function CommandsService:RegisterFindPlayerCommand()
	self.CmdrService:RegisterCommand({
		Name = "findPlayer",
		Aliases = { "find-plr", "goto-player", "tp-to-player-server", "goto-player-server" },
		Description = "Teleports you to the server that the specified player was found in.",
		Group = "Admin",
		Args = {
			{
				Type = "string",
				Name = "teleportTo",
				Description = "The player to find's username.",
			},
		},
	}, function(context, playerToFind)
		MessagingService:PublishAsync("FindPlayer", string.lower(playerToFind))

		local connection

		connection = MessagingService:SubscribeAsync("FindPlayerResponse", function(message)
			print("Received response!", message.Data)

			local placeId = message.Data.PlaceId
			local jobId = message.Data.JobId

			TeleportService:TeleportToPlaceInstance(placeId, jobId, context.Executor)

			connection:Disconnect()
			connection = nil
		end)

		task.delay(20, function()
			if connection then
				connection:Disconnect()
				return "Could not find player in time. (20s)"
			else
				return "Teleporting..."
			end
		end)
	end)
end

function CommandsService:ListenToFindPlayerCommand()
	local function findPlayer(playerToFind)
		for _, v in pairs(Players:GetPlayers()) do
			if string.lower(v.Name) == playerToFind then
				return v
			end
		end
		return nil
	end

	MessagingService:SubscribeAsync("FindPlayer", function(message)
		local playerToFind = message.Data

		local foundPlayer = findPlayer(playerToFind)

		if foundPlayer then
			print("Player found, responding now.")

			MessagingService:PublishAsync("FindPlayerResponse", {
				PlaceId = game.PlaceId,
				JobId = game.JobId,
			})
		end
	end)
end

function CommandsService:RegisterKickCommand()
	self.CmdrService:RegisterCommand({
		Name = "kick",
		Aliases = {},
		Description = "Kicks a player from the server.",
		Group = "Admin",
		Args = {
			{
				Type = "player",
				Name = "playerToKick",
				Description = "The player to kick from the game.",
			},
			{
				Type = "string",
				Name = "reason",
				Description = "The reason that the player will be shown.",
			},
		},
	}, function(_, playerToKick, reason)
		playerToKick:Kick(reason)

		return `Kicked {playerToKick.DisplayName} (@{playerToKick.Name}).`
	end)
end

function CommandsService:RegisterUnbanCommand()
	self.CmdrService:RegisterCommand({
		Name = "unban",
		Aliases = {},
		Description = "Unbans a player from the game.",
		Group = "Admin",
		Args = {
			{
				Type = "string",
				Name = "username",
				Description = "The player to unban's username.",
			},
		},
	}, function(playerToUnbanName)
		Players:UnbanAsync({
			UserIds = { Players:GetUserIdFromNameAsync(playerToUnbanName) },
			ApplyToUniverse = true,
		})

		return `Unbanned @{playerToUnbanName} from the game.`
	end)
end

function CommandsService:RegisterCashCommands()
	self.CmdrService:RegisterCommand({
		Name = "giveCash",
		Aliases = { "addCash", "add-cash", "give-cash" },
		Description = "Adds cash to a player's data.",
		Group = "Admin",
		Args = {
			{
				Type = "player",
				Name = "player",
				Description = "The player to give the cash to.",
			},
			{
				Type = "number",
				Name = "amount",
				Description = "The amount of cash.",
			},
		},
	}, function(_, player, amount)
		self.CashService:AddCash(player, amount)
	end)

	self.CmdrService:RegisterCommand({
		Name = "takeCash",
		Aliases = { "removeCash", "remove-cash", "take-cash" },
		Description = "Removes cash to a player's data.",
		Group = "Admin",
		Args = {
			{
				Type = "player",
				Name = "player",
				Description = "The player to remove the cash from.",
			},
			{
				Type = "number",
				Name = "amount",
				Description = "The amount of cash.",
			},
		},
	}, function(_, player, amount)
		self.CashService:RemoveCash(player, amount)
	end)

	self.CmdrService:RegisterCommand({
		Name = "setCash",
		Aliases = { "set-cash" },
		Description = "sets the cash in a player's data.",
		Group = "Admin",
		Args = {
			{
				Type = "player",
				Name = "player",
				Description = "The player to remove the cash from.",
			},
			{
				Type = "number",
				Name = "amount",
				Description = "The amount of cash.",
			},
		},
	}, function(_, player, amount)
		self.CashService:SetCash(player, amount)
	end)
end

function CommandsService:RegisterDebugCommands()
	local DebugRemote = Remotes.DebugCommands

	self.CmdrService:RegisterCommand(
		{
			Name = "debug-changeKeybind",
			Aliases = {},
			Description = "Changes a keybind for a specific action.",
			Group = "Admin",
			Args = {
				{
					Type = "string",
					Name = "Name",
					Description = "The name of the keybind to change.",
				},
				{
					Type = "string",
					Name = "Platform",
					Description = "The platform of the keybind. (ex. PC, CONSOLE)",
				},
				{
					Type = "userInput",
					Name = "newInput",
					Description = "The new input of the keybind.",
				},
			},
		},
		function(
			context,
			inputName: InputNames.InputName,
			inputPlatform: InputPlatforms.InputPlatform,
			newInput: Enum.UserInputType | Enum.KeyCode
		)
			print(context.Executor)
			DebugRemote:FireClient(context.Executor, inputName, inputPlatform, newInput)
		end
	)
end

function CommandsService:Start()
	self:RegisterBanCommand()

	task.spawn(function()
		self:ListenToFindPlayerCommand()
	end)
	self:RegisterFindPlayerCommand()

	self:RegisterKickCommand()

	self:RegisterUnbanCommand()

	self:RegisterCashCommands()

	if RunService:IsStudio() then
		self:RegisterDebugCommands()
	end
end

return CommandsService
