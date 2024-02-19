local Workspace = game:GetService("Workspace")
local ViewModule = {}

local Angles = {
	[30] = 0.86,
	[45] = 0.7,
	[60] = 0.5,
	[75] = 0.25,
	[90] = 0,
}

function ViewModule:IsInView(Angle: number, From: BasePart, To: BasePart): boolean
	local Position = (To.CFrame.Position - From.CFrame.Position).Unit
	local Look = From.CFrame.LookVector

	local dotProduct = Position:Dot(Look)
	local angle = Angle

	return dotProduct >= angle
end

function ViewModule:GetDist(From: BasePart, To: BasePart): number
	return (To.CFrame.Position - From.CFrame.Position).Magnitude
end

function ViewModule:ObjectInFront(From: BasePart, To: BasePart): boolean
	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	RaycastParams.FilterDescendantsInstances = { From.Parent }
	RaycastParams.RespectCanCollide = true

	local RayResult = Workspace:Raycast(From.Position, (To.Position - From.Position).Unit * 100, RaycastParams)
	if RayResult then
		return RayResult.Instance:IsDescendantOf(To.Parent)
	else
		return false
	end
end

return ViewModule
