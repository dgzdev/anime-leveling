local Path = {}
Path.InPath = false

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
	task.synchronize()
	Target = nil
	if not From then return end
	local AlignOrientation = From.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		AlignOrientation.Enabled = false
	end
	task.desynchronize()
end

function Path.StartFollowing(from: Humanoid, target: BasePart)
	local AlignOrientation = from.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		task.synchronize()
		AlignOrientation.Enabled = true
	end
	task.desynchronize()
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
		Path.InPath = true
		
		task.spawn(function()
			if (From.RootPart.Position - Target.Position).Magnitude > 50 then
				Path.LeaveFollowing()
				Path.InPath = false
				return
			end

			local p = PathfindingService:CreatePath()
			p:ComputeAsync(From.RootPart.Position, Target.Position)
			local waypoints = p:GetWaypoints()
			table.remove(waypoints, #waypoints)
			table.remove(waypoints, #waypoints - 1)
			table.remove(waypoints, #waypoints - 2)
			table.remove(waypoints, #waypoints - 3)
			--for i = 0, 10, 1 do
			--	if i < #waypoints then table.remove(waypoints, #waypoints - i) end
			--end

			for i, v in pairs(waypoints) do
				From:MoveTo(v.Position)
				--From.MoveToFinished:Wait()
			end
		end)

		task.desynchronize()
	end)
end

return Path
