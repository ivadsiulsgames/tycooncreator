local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local require = require(script.Parent.loader).load(script)

local InputSettings = require("InputSettings")

local Platform = {}

function Platform:GetLocalPlatform(): InputSettings.InputPlatform
	assert(RunService:IsClient(), "Cannot use Platform:GetLocalPlatform() in the Server.")

	local PlatformToReturn = "PC"

	if
		UserInputService.GamepadEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.TouchEnabled
	then
		PlatformToReturn = "CONSOLE"
	elseif
		UserInputService.TouchEnabled
		and not UserInputService.GamepadEnabled
		and not UserInputService.KeyboardEnabled
	then
		PlatformToReturn = "MOBILE"
	end

	return PlatformToReturn
end

return Platform
