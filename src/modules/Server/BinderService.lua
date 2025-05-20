--[=[
	@class BinderService
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local BinderService = {}
BinderService.ServiceName = "BinderService"

function BinderService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- Binders

	self._serviceBag:GetService(require("Conveyor"))
	self._serviceBag:GetService(require("Dropper"))
	self._serviceBag:GetService(require("SellPart"))
	self._serviceBag:GetService(require("CashPart"))
end

return BinderService
