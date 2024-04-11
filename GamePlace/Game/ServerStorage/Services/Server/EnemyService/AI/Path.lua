local Path = {}
local PathfindingService = game:GetService("PathfindingService")

local Target: BasePart = nil
local From: Humanoid = nil
local Task: thread = nil
local Align: AlignOrientation = nil

local defaultDelay = 0

local loop = function(thread: () -> any, ...)
	return task.spawn(function(...)
		while true do
			local stop = thread(...)
			if stop then
				break
			end
			task.wait(defaultDelay)
		end
	end)
end

function Path.LeaveFollowing()
	Target = nil

	local AlignOrientation = From.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		AlignOrientation.Enabled = false
	end
end

function Path.StartFollowing(from: Humanoid, target: BasePart)
	local AlignOrientation = from.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		AlignOrientation.Enabled = true
	end

	Align = AlignOrientation

	Target = target
	From = from
end

do
	loop(function()
		if not Target then
			return
		end

		task.synchronize()

		--> Se setar o CFrame da RootPart, o personagem fica todo travado
		--> AlignOrientation

		Align.LookAtPosition = Target.Position

		task.spawn(function()
			local p = PathfindingService:CreatePath()
			p:ComputeAsync(From.RootPart.Position, Target.Position)
			local waypoints = p:GetWaypoints()

			for i, v in waypoints do
				From:MoveTo(v.Position)
				From.MoveToFinished:Wait()
			end
		end)

		task.desynchronize()
	end)
end

return Path
