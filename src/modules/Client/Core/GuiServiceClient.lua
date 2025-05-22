--[=[
	@class GuiServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local GuiServiceClient = {}
GuiServiceClient.ServiceName = "GuiServiceClient"

function GuiServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
	self._maid = Maid.new()

	-- External

	-- Internal
	self._serviceBag:GetService(require("BuildGuiServiceClient"))
	self._serviceBag:GetService(require("CashGuiServiceClient"))
	self._serviceBag:GetService(require("DeleteGuiServiceClient"))
	self._serviceBag:GetService(require("VersionGuiServiceClient"))
end

return GuiServiceClient
