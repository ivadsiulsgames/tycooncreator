--[=[
	@class InputServiceClient
]=]

local ContextActionService = game:GetService("ContextActionService")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Signal = require("Signal")

local InputSettings = require("InputSettings")

type ControlSignals = {
	BuildActivatedSignal: Signal.Signal<any>,
	RotateBuildActivatedSignal: Signal.Signal<any>,
	DeleteBlockActivatedSignal: Signal.Signal<any>,
}

type ControlSignalName = "Build" | "RotateBuild" | "DeleteBlock"

type ControlSignalCallback = (inputState: Enum.UserInputState, inputObj: InputObject) -> ()

local InputServiceClient = {}
InputServiceClient.ServiceName = "InputServiceClient"

function InputServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal

	self.ControlSignals = {
		BuildActivatedSignal = Signal.new(),
		RotateBuildActivatedSignal = Signal.new(),
		DeleteBlockActivatedSignal = Signal.new(),
	} :: ControlSignals

	self.isBound = false
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

	ContextActionService:BindAction("Build", function(...)
		self:_handleAction(...)
	end, InputSettings.BUILD_INPUT.MOBILE, InputSettings.BUILD_INPUT.PC, InputSettings.BUILD_INPUT.CONSOLE)

	ContextActionService:BindAction(
		"RotateBuild",
		function(...)
			self:_handleAction(...)
		end,
		InputSettings.ROTATE_BUILD_INPUT.MOBILE,
		InputSettings.ROTATE_BUILD_INPUT.PC,
		InputSettings.ROTATE_BUILD_INPUT.CONSOLE
	)

	ContextActionService:BindAction(
		"DeleteBlock",
		function(...)
			self:_handleAction(...)
		end,
		InputSettings.DELETE_BLOCK_INPUT.MOBILE,
		InputSettings.DELETE_BLOCK_INPUT.PC,
		InputSettings.DELETE_BLOCK_INPUT.CONSOLE
	)
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
