local require = require(script.Parent.loader).load(script)

local Blend = require("Blend")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local SellPartBlock = {}
SellPartBlock.__index = SellPartBlock

function SellPartBlock.new(buildFrame, _serviceBag: ServiceBag.ServiceBag)
	local maid = Maid.new()

	local self = setmetatable({}, SellPartBlock)

	self._maid = maid
	self._serviceBag = _serviceBag

	self.BuildServiceClient = self._serviceBag:GetService(require("BuildServiceClient"))

	self.buildFrame = buildFrame

	self:Init()

	return self
end

function SellPartBlock:Init()
	local render = Blend.New "ImageButton" {
		Name = "SellPartBlockButton",

		Image = "rbxassetid://10049046091",

		BackgroundTransparency = 1,

		Size = UDim2.fromScale(1, 1),

		Parent = self.buildFrame,

		Blend.New "UIAspectRatioConstraint" {},

		[Blend.OnEvent "Activated"] = function()
			self.BuildServiceClient:StartPlacementMode("SellPart")

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

return SellPartBlock
