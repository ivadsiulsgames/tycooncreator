--[=[
	@class BuildGuiServiceClient
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Blend = require("Blend")
--local Rx = require("Rx")
local RxAttributeUtils = require("RxAttributeUtils")
local Maid = require("Maid")

local BuildGuiServiceClient = {}
BuildGuiServiceClient.ServiceName = "BuildGuiServiceClient"

function BuildGuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
end

function BuildGuiServiceClient:Start()
	local render = Blend.New "ScreenGui" {
		Name = "BuildScreen",

		ResetOnSpawn = false,

		Parent = Players.LocalPlayer.PlayerGui,
	
		Blend.New "Frame" {
			Name = "BuildFrame",

			AnchorPoint = Vector2.new(0.5, 1),

			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.5, 0.15),

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Blend.Spring(RxAttributeUtils.observeAttribute(workspace, "Color", Color3.new(0, 0, 0)), 3),

			Blend.New "UIListLayout" {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.02, 0),
			},

			Blend.New "UIPadding" {
				PaddingBottom = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.02, 0),
				PaddingRight = UDim.new(0.02, 0),
				PaddingTop = UDim.new(0.1, 0),
			},
		};
	};
	
	self._maid:GiveTask(render:Subscribe(function(buildScreen)
		local buildFrame = buildScreen.BuildFrame

		require("DropperBlock").new(buildFrame, self._serviceBag)
		require("ConveyorBlock").new(buildFrame, self._serviceBag)
		require("SellPartBlock").new(buildFrame, self._serviceBag)
	end))
end


return BuildGuiServiceClient