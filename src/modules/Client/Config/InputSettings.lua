local require = require(script.Parent.loader).load(script)

local Signal = require("Signal")

export type InputName = "BUILD_OR_DELETE_INPUT" | "ROTATE_BUILD_INPUT" | "DELETE_MODE_INPUT"

export type InputPlatform = "PC" | "CONSOLE" | "MOBILE"

export type Input = Enum.UserInputState | InputObject

local InputSettings = {
	BUILD_OR_DELETE_INPUT = {
		PC = Enum.UserInputType.MouseButton1,
		CONSOLE = Enum.KeyCode.ButtonX,
		MOBILE = false,
	},
	ROTATE_BUILD_INPUT = {
		PC = Enum.KeyCode.R,
		CONSOLE = Enum.KeyCode.ButtonR1,
		MOBILE = true,
	},
	DELETE_MODE_INPUT = {
		PC = Enum.KeyCode.C,
		CONSOLE = Enum.KeyCode.ButtonB,
		MOBILE = false,
	},

	Changed = Signal.new(),
}

function InputSettings:ChangeInput(inputToChangeName: InputName, inputToChangePlatform: InputPlatform, newInput: Input)
	InputSettings[inputToChangeName][inputToChangePlatform] = newInput

	InputSettings.Changed:Fire(newInput, inputToChangeName, inputToChangePlatform)

	return InputSettings[inputToChangeName][inputToChangePlatform]
end

return InputSettings
