--[=[
	@class VersionGuiServiceClient
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local VersionGuiServiceClient = {}
VersionGuiServiceClient.ServiceName = "VersionGuiServiceClient"

function VersionGuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
end

function VersionGuiServiceClient:Start()
	local render = Blend.New "ScreenGui" {
		Name = "VersionScreen",

		ResetOnSpawn = false,
		IgnoreGuiInset = true,

		Parent = Players.LocalPlayer.PlayerGui,

		Blend.New "UIPadding" {
			PaddingBottom = UDim.new(0.01, 0),
			PaddingLeft = UDim.new(0.01, 0),
		},

		Blend.New "TextLabel" {
			AnchorPoint = Vector2.new(0, 1),

			Position = UDim2.fromScale(0, 1),

			Size = UDim2.fromScale(0.2, 0.07),

			BackgroundTransparency = 1,

			Name = "VersionLabel",

			RichText = true,

			Text = "<b>Loading version...</b>",
			TextColor3 = Color3.fromRGB(255, 255, 255),

			TextTransparency = 0.4,

			TextXAlignment = Enum.TextXAlignment.Left,

			TextScaled = true,
		},
	}

	render:Subscribe(function(VersionScreen)
		local VersionLabel = VersionScreen.VersionLabel

		local VersionName = ReplicatedStorage.VersionName

		VersionLabel.Text = `<b>{VersionName.Value}</b>`

		VersionName.Changed:Connect(function(value)
			VersionLabel.Text = `<b>{value}</b>`
		end)
	end)
end

return VersionGuiServiceClient
