--[=[
	@class DeleteGuiServiceClient
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")
local ServiceBag = require("ServiceBag")

local DeleteGuiServiceClient = {}
DeleteGuiServiceClient.ServiceName = "DeleteGuiServiceClient"

function DeleteGuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
	self.BuildServiceClient = self._serviceBag:GetService(require("BuildServiceClient"))
	self.InputServiceClient = self._serviceBag:GetService(require("InputServiceClient"))
end

function DeleteGuiServiceClient:Start()
	local render = Blend.New "ScreenGui" {
		Name = "DeleteScreen",

		ResetOnSpawn = false,

		Parent = Players.LocalPlayer.PlayerGui,

		Blend.New "Frame" {
			Name = "DeleteFrame",

			AnchorPoint = Vector2.new(0.5, 1),

			Position = UDim2.fromScale(0.8, 1),
			Size = UDim2.fromScale(0.1, 0.15),

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Blend.Spring(
				RxAttributeUtils.observeAttribute(Players.LocalPlayer.PlayerGui, "PrimaryColor", Color3.new(0, 0, 0)),
				3
			),

			Blend.New "UIAspectRatioConstraint" {},

			Blend.New "ImageButton" {
				AnchorPoint = Vector2.new(0.5, 0.5),

				Position = UDim2.fromScale(0.5, 0.5),

				Size = UDim2.fromScale(0.9, 0.9),

				BackgroundTransparency = 1,

				Name = "DeleteButton",

				Image = "rbxassetid://13497175064",

				Blend.New "UIAspectRatioConstraint" {},

				[Blend.OnEvent "Activated"] = function()
					if not self.BuildServiceClient:IsDeleting() then
						self.BuildServiceClient:StartDeleteMode()
					end
				end,
			},

			Blend.New "ImageLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),

				Position = UDim2.fromScale(0.95, 0.05),

				Size = UDim2.fromScale(0.35, 0.35),

				BackgroundTransparency = 1,

				Name = "DeleteModeInputIcon",

				Blend.New "UIAspectRatioConstraint" {},
			},
		},
	}

	self._maid:GiveTask(render:Subscribe(function(deleteScreen)
		local deleteFrame = deleteScreen:FindFirstChild("DeleteFrame")
		local inputImageLabel = deleteFrame:FindFirstChild("DeleteModeInputIcon")

		self.InputServiceClient:StyleImageToInputIcon(inputImageLabel, "DELETE_MODE_INPUT")
	end))
end

return DeleteGuiServiceClient
