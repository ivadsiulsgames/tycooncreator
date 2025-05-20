--[=[
	@class GameService
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local GameService = {}
GameService.ServiceName = "GameService"

function GameService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal
	serviceBag:GetService(require("BinderService"))
	serviceBag:GetService(require("BuildService"))
	serviceBag:GetService(require("DataService"))
	serviceBag:GetService(require("CashService"))
	serviceBag:GetService(require("CommandsService"))
end

return GameService
