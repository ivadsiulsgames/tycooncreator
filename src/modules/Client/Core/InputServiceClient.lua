--[=[
	@class InputServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local InputServiceClient = {}
InputServiceClient.ServiceName = "InputServiceClient"

function InputServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal
end

return InputServiceClient