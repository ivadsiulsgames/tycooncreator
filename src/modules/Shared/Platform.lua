local UserInputService = game:GetService("UserInputService")

local require = require(script.Parent.loader).load(script)

local InputSettings = require("InputSettings")
local Observable = require("Observable")
local Subscription = require("Subscription")

local Platform = {}

function Platform:GetLocalPlatform(): InputSettings.InputPlatform
	local PlatformToReturn = "PC"

	local function isEqualToAnyOf(mainVal, ...)
		for _, v in { ... } do
			if mainVal == v then
				return true
			end
		end

		return false
	end

	if
		isEqualToAnyOf(
			UserInputService:GetLastInputType(),
			Enum.UserInputType.Gamepad1,
			Enum.UserInputType.Gamepad2,
			Enum.UserInputType.Gamepad3,
			Enum.UserInputType.Gamepad4,
			Enum.UserInputType.Gamepad5,
			Enum.UserInputType.Gamepad6,
			Enum.UserInputType.Gamepad7,
			Enum.UserInputType.Gamepad8
		)
	then
		PlatformToReturn = "CONSOLE"
	elseif
		isEqualToAnyOf(
			UserInputService:GetLastInputType(),
			Enum.UserInputType.Touch,
			Enum.UserInputType.Accelerometer,
			Enum.UserInputType.Gyro
		)
	then
		PlatformToReturn = "MOBILE"
	end

	return PlatformToReturn
end

function Platform:ObserveLocalPlatform()
	return Observable.new(function(subscription: Subscription.Subscription<InputSettings.InputPlatform>)
		local currentPlatform = self:GetLocalPlatform()

		-- sadly can't use ContextActionService for this (i think)
		UserInputService.InputBegan:Connect(function()
			if Platform:GetLocalPlatform() ~= currentPlatform then
				currentPlatform = Platform:GetLocalPlatform()
				subscription:Fire(currentPlatform)
			end
		end)

		subscription:Fire(currentPlatform)
	end)
end

return Platform
