--[=[
	@class BinderServiceClient
]=]

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local BinderServiceClient = {}
BinderServiceClient.ServiceName = "BinderServiceClient"

function BinderServiceClient:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")
end

function BinderServiceClient:Start()
    local Binders = script.Parent.Parent.Binders:GetDescendants()
    
    for _, binder in Binders do
        if binder:IsA("ModuleScript") then
            require(binder.Name)
        end
    end
end

return BinderServiceClient