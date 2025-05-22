--[=[
	@class CashService
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local CashService = {}
CashService.ServiceName = "CashService"

function CashService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal
	self.DataService = self._serviceBag:GetService(require("DataService"))
end

function CashService:GetCashValue(player: Player)
	local playerData = self.DataService:GetPlayerDataFolder(player)

	local cashValue = assert(playerData:FindFirstChild("Cash"), "CashValue IntValue not found.")

	return cashValue
end

function CashService:SetCash(player: Player, amount: number)
	if not player then
		return
	end

	local cashValue = self:GetCashValue(player)

	cashValue.Value = amount
end

function CashService:AddCash(player: Player, increment: number)
	if not player then
		return
	end

	local cashValue = self:GetCashValue(player)

	cashValue.Value += increment
end

function CashService:RemoveCash(player: Player, decrement: number)
	local cashValue = self:GetCashValue(player)

	cashValue.Value -= decrement
end

function CashService:Start() end

return CashService
