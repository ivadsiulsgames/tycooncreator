--[=[
	@class BuildGuiServiceClient
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local ServiceBag = require("ServiceBag")
--local Rx = require("Rx")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")

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
			BackgroundColor3 = Blend.Spring(
				RxAttributeUtils.observeAttribute(Players.LocalPlayer.PlayerGui, "PrimaryColor", Color3.new(0, 0, 0)),
				3
			),

			Blend.New "UIListLayout" {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.02, 0),
			},

			Blend.New "UIPadding" {
				PaddingBottom = UDim.new(0.1, 0),
				PaddingLeft = UDim.new(0.02, 0),
				PaddingRight = UDim.new(0.02, 0),
				PaddingTop = UDim.new(0.1, 0),
			},
		},
	}

	local cam = Blend.New "Camera" {
		Name = "ViewportCamera",

		CFrame = CFrame.new(Vector3.new(0, 20, 0)) * CFrame.Angles(math.rad(-22.5), math.rad(0), math.rad(0)),

		FieldOfView = 50,

		Parent = Players.LocalPlayer.PlayerGui,
	}

	cam:Subscribe(function(camera)
		self.viewportCamera = camera
	end)

	self._maid:GiveTask(render:Subscribe(function(buildScreen)
		local buildFrame = buildScreen.BuildFrame

		require("DropperBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		require("ConveyorBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		require("SellPartBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		require("FenceBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
	end))
end

return BuildGuiServiceClient
