--[=[
	@class GuiServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

local GuiServiceClient = {}
GuiServiceClient.ServiceName = "GuiServiceClient"

function GuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
	self._serviceBag:GetService(require("BuildGuiServiceClient"))

end


return GuiServiceClient