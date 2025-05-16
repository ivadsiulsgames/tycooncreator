--[=[
	@class BuildService
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local require = require(script.Parent.loader).load(script)

local ServiceBag = require("ServiceBag")

local CalculateGridCF = require("CalculateGridCF")

local BuildService = {}
BuildService.ServiceName = "BuildService"

function BuildService:Init(serviceBag: ServiceBag.ServiceBag)
	assert(not self._serviceBag, "Already initialized")
	self._serviceBag = assert(serviceBag, "No serviceBag")

	-- External

	-- Internal
	self.PlaceBlockRemote = ReplicatedStorage.Remotes.PlaceBlock

	self:_connectToPlaceBlockRemote()
end

function BuildService:_connectToPlaceBlockRemote()
	self.PlaceBlockRemote.OnServerEvent:Connect(
		function(_, blockName: string, hitPos: Vector3, mouseTarget: Instance, blockRot: Vector3, blockOwner: Player)
			if not mouseTarget or not hitPos or not mouseTarget:HasTag("Buildable") or not blockRot then
				return
			end

			local block = ReplicatedStorage.Assets.Blocks[blockName]

			if not block then
				return
			end

			local blockClone = block:Clone()

			local gridCF = CalculateGridCF(hitPos, Vector3.new(0, 1, 0), mouseTarget, false, 0)

			local cframe = gridCF * CFrame.Angles(math.rad(blockRot.X), math.rad(blockRot.Y), math.rad(blockRot.Z))

			blockClone:PivotTo(cframe)

			local partsInside = 0

			local HitboxParts = blockClone:FindFirstChild("Hitboxes"):GetDescendants()

			if not HitboxParts then
				return
			end

			for _, hitbox in HitboxParts do
				for _, part in workspace:GetPartsInPart(hitbox) do
					if
						not part:IsDescendantOf(blockClone)
						and not part:HasTag("Buildable")
						and not Players:GetPlayerFromCharacter(part.Parent)
						and not Players:GetPlayerFromCharacter(part.Parent.Parent)
						and part:FindFirstAncestor("Workspace")
						and not part:HasTag("CashPart")
					then
						partsInside += 1
					end
				end
			end

			if partsInside > 0 then
				blockClone:Destroy()
				return
			end

			blockClone:SetAttribute("Owner", blockOwner.UserId)
			blockClone.Parent = workspace.Blocks
		end
	)
end

return BuildService
