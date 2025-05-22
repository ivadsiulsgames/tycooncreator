--[=[
	@class InputServiceClient
]=]

local ContextActionService = game:GetService("ContextActionService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

local InputSettings = require("InputSettings")
local Platform = require("Platform")

type ControlSignals = {
	BuildOrDeleteActivatedSignal: Signal.Signal<any>,
	RotateBuildActivatedSignal: Signal.Signal<any>,
	DeleteModeActivatedSignal: Signal.Signal<any>,
}

type ControlSignalName = "BuildOrDelete" | "RotateBuild" | "DeleteMode"

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
	} :: ControlSignals

	self.isBound = false

	self.actionNames = {
		BUILD_OR_DELETE = "BuildOrDelete",
		ROTATE_BUILD = "RotateBuild",
		DELETE_MODE = "DeleteMode",
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

	self._maid:GiveTask(InputSettings.Changed:Connect(function(_, inputName: InputSettings.InputName, _)
		print(inputName)

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

	ContextActionService:UnbindAction("Build")
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

return InputServiceClient
