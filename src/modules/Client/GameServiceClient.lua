--[=[
	@class GameServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameServiceClient = {}
GameServiceClient.ServiceName = "GameServiceClient"

function GameServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External
	self._serviceBag:GetService(require("CmdrServiceClient"))

	-- Internal
	serviceBag:GetService(require("GuiServiceClient"))
	serviceBag:GetService(require("BinderServiceClient"))
	serviceBag:GetService(require("BuildServiceClient"))
	serviceBag:GetService(require("InputServiceClient"))
end

return GameServiceClient