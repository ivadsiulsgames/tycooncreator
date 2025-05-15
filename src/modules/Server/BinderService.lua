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
end

function BinderService:Start()
    local Binders = script.Parent.Binders:GetDescendants()
    
    for _, binder in Binders do
        if binder:IsA("ModuleScript") then
            require(binder.Name)
        end
    end
end

return BinderService