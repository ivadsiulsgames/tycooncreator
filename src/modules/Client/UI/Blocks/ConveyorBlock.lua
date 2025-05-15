local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local ConveyorBlock = {}
ConveyorBlock.__index = ConveyorBlock

function ConveyorBlock.new(buildFrame, _serviceBag: ServiceBag.ServiceBag)
	local maid = Maid.new()

	local self = setmetatable({}, ConveyorBlock)

	self._maid = maid
	self._serviceBag = _serviceBag

	self.BuildServiceClient = self._serviceBag:GetService(require("BuildServiceClient"))

	self.buildFrame = buildFrame

	self:Init()

	return self
end

function ConveyorBlock:Init()
	local render = Blend.New "ImageButton" {
		Name = "ConveyorBlockButton",

		Image = "rbxassetid://3190781898",

		BackgroundTransparency = 1,

		Size = UDim2.fromScale(1, 1),

		Parent = self.buildFrame,

		Blend.New "UIAspectRatioConstraint" {},

		[Blend.OnEvent "Activated"] = function()
			self.BuildServiceClient:StartPlacementMode("Conveyor")

			self.closeButton.Visible = true

			self._maid:GiveTask(self.BuildServiceClient:GetPlacementStoppedSignal():Connect(function()
				self.closeButton.Visible = false
			end))
		end,
	}

	render:Subscribe(function(button)
		self.mainButton = button
	end)

	local closeButton = Blend.New "ImageButton" {
		Name = "CloseButton",

		Image = "rbxassetid://1249929622",

		BackgroundTransparency = 1,

		Size = UDim2.fromScale(1, 1),

		Visible = false,

		Parent = self.mainButton,

		[Blend.OnEvent "Activated"] = function()
			self.BuildServiceClient:StopPlacementMode()
		end,
	}

	closeButton:Subscribe(function(button)
		self.closeButton = button
	end)
end

return ConveyorBlock
