--[=[
	@class InputServiceClient

	made this cool thing
]=]

local ContextActionService = game:GetService("ContextActionService")

local require = require(script.Parent.loader).load(script)

local InputImageLibrary = require("InputImageLibrary")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

local InputSettings = require("InputSettings")
local Platform = require("Platform")
local PlayerSettings = require("PlayerSettings")

type ControlSignals = {
	BuildOrDeleteActivatedSignal: Signal.Signal<any>,
	RotateBuildActivatedSignal: Signal.Signal<any>,
	DeleteModeActivatedSignal: Signal.Signal<any>,
	Block1ActivatedSignal: Signal.Signal<any>,
	Block2ActivatedSignal: Signal.Signal<any>,
	Block3ActivatedSignal: Signal.Signal<any>,
	Block4ActivatedSignal: Signal.Signal<any>,
	Block5ActivatedSignal: Signal.Signal<any>,
}

type ControlSignalName =
	"BuildOrDelete"
	| "RotateBuild"
	| "DeleteMode"
	| "Block1"
	| "Block2"
	| "Block3"
	| "Block4"
	| "Block5"

type ControlSignalCallback = (inputState: Enum.UserInputState, inputObj: InputObject) -> ()

local InputServiceClient = {}
InputServiceClient.ServiceName = "InputServiceClient"

function InputServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal

	self.ControlSignals = {
		BuildOrDeleteActivatedSignal = Signal.new(),
		RotateBuildActivatedSignal = Signal.new(),
		DeleteModeActivatedSignal = Signal.new(),
		Block1ActivatedSignal = Signal.new(),
		Block2ActivatedSignal = Signal.new(),
		Block3ActivatedSignal = Signal.new(),
		Block4ActivatedSignal = Signal.new(),
		Block5ActivatedSignal = Signal.new(),
	} :: ControlSignals

	self.isBound = false

	self.actionNames = {
		BUILD_OR_DELETE = "BuildOrDelete",
		ROTATE_BUILD = "RotateBuild",
		DELETE_MODE = "DeleteMode",
		BLOCK_1 = "Block1",
		BLOCK_2 = "Block2",
		BLOCK_3 = "Block3",
		BLOCK_4 = "Block4",
		BLOCK_5 = "Block5",
	}
end

function InputServiceClient:Start()
	self:BindControls()
end

function InputServiceClient:_handleAction(action: string, inputState: Enum.UserInputState, inputObj: InputObject)
	if inputState == Enum.UserInputState.End then
		local signalName = `{action}ActivatedSignal`

		self.ControlSignals[signalName]:Fire(inputState, inputObj)
		return Enum.ContextActionResult.Pass
	else
		return Enum.ContextActionResult.Pass
	end
end

function InputServiceClient:BindControls()
	if self.isBound then
		return
	end
	self.isBound = true

	--// BUILDING AND DELETION

	ContextActionService:BindAction(
		self.actionNames.BUILD_OR_DELETE,
		function(...)
			self:_handleAction(...)
		end,
		InputSettings.BUILD_OR_DELETE_INPUT.MOBILE,
		InputSettings.BUILD_OR_DELETE_INPUT.PC,
		InputSettings.BUILD_OR_DELETE_INPUT.CONSOLE
	)

	ContextActionService:BindAction(
		self.actionNames.ROTATE_BUILD,
		function(...)
			self:_handleAction(...)
		end,
		InputSettings.ROTATE_BUILD_INPUT.MOBILE,
		InputSettings.ROTATE_BUILD_INPUT.PC,
		InputSettings.ROTATE_BUILD_INPUT.CONSOLE
	)

	ContextActionService:BindAction(
		self.actionNames.DELETE_MODE,
		function(...)
			self:_handleAction(...)
		end,
		InputSettings.DELETE_MODE_INPUT.MOBILE,
		InputSettings.DELETE_MODE_INPUT.PC,
		InputSettings.DELETE_MODE_INPUT.CONSOLE
	)

	--// BLOCK NUMBER HOTKEYS

	ContextActionService:BindAction(self.actionNames.BLOCK_1, function(...)
		self:_handleAction(...)
	end, InputSettings.BLOCK_1_INPUT.MOBILE, InputSettings.BLOCK_1_INPUT.PC, InputSettings.BLOCK_1_INPUT.CONSOLE)

	ContextActionService:BindAction(self.actionNames.BLOCK_2, function(...)
		self:_handleAction(...)
	end, InputSettings.BLOCK_2_INPUT.MOBILE, InputSettings.BLOCK_2_INPUT.PC, InputSettings.BLOCK_2_INPUT.CONSOLE)

	ContextActionService:BindAction(self.actionNames.BLOCK_3, function(...)
		self:_handleAction(...)
	end, InputSettings.BLOCK_3_INPUT.MOBILE, InputSettings.BLOCK_3_INPUT.PC, InputSettings.BLOCK_3_INPUT.CONSOLE)

	ContextActionService:BindAction(self.actionNames.BLOCK_4, function(...)
		self:_handleAction(...)
	end, InputSettings.BLOCK_4_INPUT.MOBILE, InputSettings.BLOCK_4_INPUT.PC, InputSettings.BLOCK_4_INPUT.CONSOLE)

	ContextActionService:BindAction(self.actionNames.BLOCK_5, function(...)
		self:_handleAction(...)
	end, InputSettings.BLOCK_5_INPUT.MOBILE, InputSettings.BLOCK_5_INPUT.PC, InputSettings.BLOCK_5_INPUT.CONSOLE)

	--// HANDLE CHANGES

	self._maid:GiveTask(InputSettings.Changed:Connect(function(_, inputName: InputSettings.InputName, _)
		local tableName = string.split(inputName, "_INPUT")[1]

		ContextActionService:UnbindAction(self.actionNames[tableName])

		ContextActionService:BindAction(self.actionNames[tableName], function(...)
			self:_handleAction(...)
		end, InputSettings[inputName].MOBILE, InputSettings[inputName].PC, InputSettings[inputName].CONSOLE)
	end))
end

function InputServiceClient:UnbindControls()
	if self.isBound then
		return
	end
	self.isBound = true

	for _, v in self.actionNames do
		ContextActionService:UnbindAction(v)
	end
end

function InputServiceClient:BindToSignal(
	signalName: ControlSignalName,
	signalCallback: ControlSignalCallback
): Signal.Connection<any>
	local trueName = `{signalName}ActivatedSignal`
	local signal = self.ControlSignals[trueName]

	if signal then
		return signal:Connect(signalCallback)
	else
		error(`Couldn't find signal: {signalName} ({trueName})`)
	end
end

-- using InputImageLibrary
function InputServiceClient:StyleImageToInputIcon(image: ImageButton | ImageLabel, inputName: InputSettings.InputName)
	self._maid:GiveTask(
		InputSettings.Changed:Connect(
			function(
				newInput: InputSettings.Input,
				name: InputSettings.InputName,
				inputPlatform: InputSettings.InputPlatform
			)
				if Platform:GetLocalPlatform() ~= inputPlatform or name ~= inputName then
					return
				end

				InputImageLibrary:StyleImage(image, newInput, PlayerSettings.Theme)
			end
		)
	)

	self._maid:GiveTask(Platform:ObserveLocalPlatform():Subscribe(function(newPlatform: InputSettings.InputPlatform)
		local newInput = InputSettings[inputName][newPlatform]

		InputImageLibrary:StyleImage(image, newInput, PlayerSettings.Theme)
	end))
end

return InputServiceClient
