--[=[
	@class BuildGuiServiceClient
]=]

local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local RxAttributeUtils = require("RxAttributeUtils")
local ServiceBag = require("ServiceBag")

local InputSettings = require("InputSettings")

local BuildGuiServiceClient = {}
BuildGuiServiceClient.ServiceName = "BuildGuiServiceClient"

function BuildGuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
	self.InputServiceClient = self._serviceBag:GetService(require("InputServiceClient"))

	self.blockModules = {}
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

		Blend.New "Frame" {
			Name = "SearchFrame",

			AnchorPoint = Vector2.new(1, 1),

			Position = UDim2.fromScale(0.75, 0.84),
			Size = UDim2.fromScale(0.2, 0.07),

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Blend.Spring(
				RxAttributeUtils.observeAttribute(Players.LocalPlayer.PlayerGui, "PrimaryColor", Color3.new(0, 0, 0)),
				3
			),

			Blend.New "ImageLabel" {
				Name = "SearchIcon",

				AnchorPoint = Vector2.new(0, 0.5),

				Position = UDim2.fromScale(0.01, 0.5),
				Size = UDim2.fromScale(0.9, 0.9),

				BackgroundTransparency = 1,

				Image = "rbxassetid://96060641709608",

				Blend.New "UIAspectRatioConstraint" {},
			},

			Blend.New "TextBox" {
				Name = "SearchBox",

				AnchorPoint = Vector2.new(1, 0.5),

				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.8, 1),

				BackgroundTransparency = 1,

				TextScaled = true,

				TextColor3 = Color3.fromRGB(255, 255, 255),
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
		local buildFrame = buildScreen.BuildFrame :: Frame

		self.blockModules.DropperBlock = require("DropperBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		self.blockModules.ConveyorBlock =
			require("ConveyorBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		self.blockModules.SellPartBlock =
			require("SellPartBlock").new(buildFrame, self._serviceBag, self.viewportCamera)
		self.blockModules.FenceBlock = require("FenceBlock").new(buildFrame, self._serviceBag, self.viewportCamera)

		local function setInputIcons()
			local index = 0
			for _, button in buildFrame:GetChildren() do
				if button:IsA("ImageButton") and index <= 5 then
					index += 1

					local inputIcon = button:FindFirstChild("InputIcon")

					local inputName = `BLOCK_{tostring(index)}_INPUT`

					local module = self.blockModules[string.split(button.Name, "Button")[1]]

					self.InputServiceClient:BindToSignal(`Block{index}`, function()
						module:_onActivated()
					end)

					if InputSettings[inputName] then
						self.InputServiceClient:StyleImageToInputIcon(inputIcon, inputName)
					end
				end
			end
		end

		setInputIcons()

		self._maid:GiveTask(buildFrame.ChildAdded:Connect(function(child: Instance)
			if child:IsA("ImageButton") then
				setInputIcons()
			end
		end))
	end))
end

return BuildGuiServiceClient
