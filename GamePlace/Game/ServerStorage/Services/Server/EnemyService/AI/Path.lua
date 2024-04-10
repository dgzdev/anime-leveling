local Path = {}
local PathfindingService = game:GetService("PathfindingService")
local Target: BasePart = nil
local Task: thread = nil

local defaultDelay = 0.25

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
	if Task then
		task.cancel(Task)
		Task = nil
	end
end

function Path.StartFollowing(from: Humanoid, target: BasePart)
	Target = target

	Task = loop(function()
		if not Target then
			return true
		end

		--> seguir o target: basepart

		task.synchronize()

		local Path = PathfindingService:CreatePath()
		Path:ComputeAsync(from.RootPart.Position, target.Position)
		local waypoints = Path:GetWaypoints()
		--> cria o path

		for i, v in pairs(waypoints) do
			from:MoveTo(v.Position)
			from.MoveToFinished:Wait()
		end

		task.desynchronize()
	end)
end

return Path
