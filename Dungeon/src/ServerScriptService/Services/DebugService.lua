local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DebugService = Knit.CreateService({
	Name = "DebugService",
})

DebugService.Activated = false

function DebugService:CreatePathBetweenTwoPoints(Origin: CFrame, FinalPos: CFrame, RayResult: RaycastResult?)
	local LastCFR = Origin
	local Distance = (Origin.Position - FinalPos.Position).Magnitude
	local DistanceToResult

	if RayResult then
		local pos = RayResult.Position
		DistanceToResult = (Origin.Position - pos).Magnitude
	end

	local parts = {}

	local debugPart = Instance.new("Part")
	debugPart.Parent = workspace:WaitForChild("Debug")
	debugPart.Anchored = true
	debugPart.Transparency = 0
	debugPart.Color = Color3.new(0, 1, 0)
	debugPart.CanCollide = false
	debugPart.Size = Vector3.new(1, 1, 1)
	debugPart.Name = "Path_Start"
	debugPart.CFrame = Origin
	debugPart.Shape = Enum.PartType.Ball
	debugPart.Material = Enum.Material.Neon

	table.insert(parts, debugPart)

	local debugPart3 = Instance.new("Part")
	debugPart3.Parent = workspace:WaitForChild("Debug")
	debugPart3.Anchored = true
	debugPart3.Transparency = 0
	debugPart3.Color = Color3.new(0, 0, 1)
	debugPart3.CanCollide = false
	debugPart3.Name = "End_Path"
	debugPart3.Size = Vector3.new(1, 1, 1)
	debugPart3.CFrame = FinalPos
	debugPart3.Shape = Enum.PartType.Ball
	debugPart3.Material = Enum.Material.Neon

	table.insert(parts, debugPart3)

	task.spawn(function()
		for i = 0, Distance, 1 do
			if RayResult then
				if i <= DistanceToResult then
					local debugPart5 = Instance.new("Part")
					debugPart5.Parent = workspace:WaitForChild("Debug")
					debugPart5.Anchored = true
					debugPart5.Transparency = 0
					debugPart5.Color = Color3.new(1, 0, 0)
					debugPart5.CanCollide = false
					debugPart5.Size = Vector3.new(0.3, 0.3, 0.3)
					debugPart5.Name = `Path_{i}`
					debugPart5.CFrame = LastCFR * CFrame.new(0, 0, -1)
					debugPart5.Shape = Enum.PartType.Ball
					debugPart5.Material = Enum.Material.Neon
					LastCFR = debugPart5.CFrame

					table.insert(parts, debugPart5)
				else
					local debugPart4 = Instance.new("Part")
					debugPart4.Parent = workspace:WaitForChild("Debug")
					debugPart4.Anchored = true
					debugPart4.Transparency = 0
					debugPart4.Color = Color3.new(0, 0, 1)
					debugPart4.CanCollide = false
					debugPart4.Size = Vector3.new(0.3, 0.3, 0.3)
					debugPart4.Name = `Path_{i}`
					debugPart4.CFrame = LastCFR * CFrame.new(0, 0, -1)
					debugPart4.Shape = Enum.PartType.Ball
					debugPart4.Material = Enum.Material.Neon
					LastCFR = debugPart4.CFrame

					table.insert(parts, debugPart4)
				end
			else
				local debugPart4 = Instance.new("Part")
				debugPart4.Parent = workspace:WaitForChild("Debug")
				debugPart4.Anchored = true
				debugPart4.Transparency = 0
				debugPart4.Color = Color3.new(0, 0, 1)
				debugPart4.CanCollide = false
				debugPart4.Size = Vector3.new(0.3, 0.3, 0.3)
				debugPart4.Name = `Path_{i}`
				debugPart4.CFrame = LastCFR * CFrame.new(0, 0, -1)
				debugPart4.Shape = Enum.PartType.Ball
				debugPart4.Material = Enum.Material.Neon
				LastCFR = debugPart4.CFrame

				table.insert(parts, debugPart4)
			end
		end
	end)

	--task.spawn(function()
	--	if RayResult then
	--		local pos = RayResult.Position --> simplesmente isso
	--		local LastCFResult = Origin
	--		DistanceToResult = (Origin.Position - pos).Magnitude
	--
	--		for i = 0, DistanceToResult, 1 do
	--			local debugPart5 = Instance.new("Part")
	--			debugPart5.Parent = workspace:WaitForChild("Debug")
	--			debugPart5.Anchored = true
	--			debugPart5.Transparency = 0
	--			debugPart5.Color = Color3.new(1, 0, 0)
	--			debugPart5.CanCollide = false
	--			debugPart5.Size = Vector3.new(0.3, 0.3, 0.3)
	--			debugPart5.Name = `Path_{i}`
	--			debugPart5.CFrame = LastCFResult * CFrame.new(0, 0, -1)
	--			debugPart5.Shape = Enum.PartType.Ball
	--			debugPart5.Material = Enum.Material.Neon
	--			LastCFResult = debugPart5.CFrame
	--
	--			table.insert(parts, debugPart5)
	--		end
	--	end
	--end)

	for _, part: BasePart in parts do
		Debris:AddItem(part, 2)
	end

	table.clear(parts)
end

return DebugService
