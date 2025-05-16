--[=[
	@class CashGuiServiceClient
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local ServiceBag = require("ServiceBag")
--local Rx = require("Rx")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")

local CashGuiServiceClient = {}
CashGuiServiceClient.ServiceName = "CashGuiServiceClient"

function CashGuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
end

function CashGuiServiceClient:Start()
	local render = Blend.New "ScreenGui" {
		Name = "CashScreen",

		ResetOnSpawn = false,
		IgnoreGuiInset = true,

		Parent = Players.LocalPlayer.PlayerGui,

		Blend.New "Frame" {
			Name = "CashFrame",

			AnchorPoint = Vector2.new(0.5, 0),

			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.15, 0.1),

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Blend.Spring(
				RxAttributeUtils.observeAttribute(Players.LocalPlayer.PlayerGui, "PrimaryColor", Color3.new(0, 0, 0)),
				3
			),

			Blend.New "UIPadding" {
				PaddingBottom = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.02, 0),
				PaddingRight = UDim.new(0.02, 0),
				PaddingTop = UDim.new(0.1, 0),
			},

			Blend.New "TextLabel" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Name = "CashLabel",

				RichText = true,

				Text = "<b>$1,000</b>",
				TextColor3 = Color3.fromRGB(0, 255, 0),

				TextScaled = true,
			},
		},
	}

	self._maid:GiveTask(render:Subscribe(function(CashScreen)
		local cashLabel = CashScreen:FindFirstChild("CashFrame"):FindFirstChild("CashLabel")

		local playerData = Players.LocalPlayer:WaitForChild("PlayerData")
		local cashValue = playerData:WaitForChild("Cash")

		cashLabel.Text = `<b>${cashValue.Value}</b>`

		cashValue.Changed:Connect(function(value)
			cashLabel.Text = `<b>${value}</b>`
		end)
	end))
end

return CashGuiServiceClient
