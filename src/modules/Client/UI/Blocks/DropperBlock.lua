local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local Blend = require("Blend")

local DropperBlock = {}
DropperBlock.__index = DropperBlock

function DropperBlock.new(buildFrame, _serviceBag: ServiceBag.ServiceBag)
    local maid = Maid.new()

    local self = setmetatable({}, DropperBlock)

    self._maid = maid
    self._serviceBag = _serviceBag

    self.BuildServiceClient = self._serviceBag:GetService(require("BuildServiceClient"))

    self.buildFrame = buildFrame

    self:Init()

    return self
end

function DropperBlock:Init()
    local render = Blend.New "ImageButton" {
        Name = "DropperBlockButton",

        Image = "rbxassetid://11752199121",

        BackgroundTransparency = 1,

        Size = UDim2.fromScale(1, 1),

        Parent = self.buildFrame,

        Blend.New "UIAspectRatioConstraint" {},

        [Blend.OnEvent "Activated"] = function()
            self.BuildServiceClient:StartPlacementMode("Dropper")
        end
    }

    render:Subscribe()
end

return DropperBlock