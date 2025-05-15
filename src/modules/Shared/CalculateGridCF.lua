local gridSize = 3

local MATRIX_ROTATION = CFrame.new(0, 0, 0,
	0, 0, 1, 
	0, 1, 0, 
	-1, 0, 0
)
local CORNERS = {
	Vector3.new(1, 1, 1),
	Vector3.new(1, 1, -1),
	Vector3.new(-1, 1, 1),
	Vector3.new(-1, 1, -1),
}

local function powCframe(cframe, pow)
	local final_CFrame = CFrame.identity
	if pow == 0 then return final_CFrame end

	for _ = 1, pow, 1 do
		final_CFrame *= cframe
	end
	return final_CFrame
end

local function getClosestCorner(position: Vector3, part: BasePart): (Vector3, Vector3, Vector3)
	local best, maxDist, difference, usedCorner = Vector3.zero, math.huge, Vector3.zero, Vector3.zero

	for _, corner in pairs(CORNERS) do
		local worldPosition = part.CFrame * (Vector3.new(
			corner.X * (part.Size.X/2),
			corner.Y * (part.Size.Y/2),
			corner.Z * (part.Size.Z/2)
			) - (Vector3.new(gridSize/2, gridSize/2, gridSize/2) * corner))

		local diff = (worldPosition - position)

		if diff.Magnitude < maxDist then
			usedCorner = corner
			maxDist = diff.Magnitude
			best = worldPosition
			difference = diff
		end
	end

	return best, difference, usedCorner
end



return function(mouseHit: Vector3, normal: Vector3, targetPart: BasePart, turnOnNormal: boolean, blockRotation: number): CFrame
	local cornerPos: Vector3, diff: Vector3, _ = getClosestCorner(mouseHit, targetPart)

	local finalPos = cornerPos - Vector3.new(
		math.round(diff.X/gridSize) * gridSize,
		math.round(diff.Y/gridSize) * gridSize,
		math.round(diff.Z/gridSize) * gridSize
	)

	local final_CFrame = CFrame.new(finalPos)
	if turnOnNormal then
		final_CFrame *= CFrame.lookAt(final_CFrame.Position, final_CFrame.Position + normal).Rotation
	end

	final_CFrame *= powCframe(MATRIX_ROTATION, blockRotation)

	return final_CFrame
end