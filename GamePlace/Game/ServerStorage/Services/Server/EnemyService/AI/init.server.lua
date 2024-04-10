local RunService = game:GetService("RunService")

local Path = require(script.Path)
local Finder = require(script.Finder)

do --> começa a buscar o humanoid
	if script.Parent:IsA("Actor") then
		local NPC: Model = script:FindFirstAncestorOfClass("Model")
		local Humanoid: Humanoid = NPC:FindFirstChildWhichIsA("Humanoid", true)

		task.spawn(function()
			while true do
				local closest = Finder.GetClosestHumanoid(Humanoid, true, 15)
				if not closest then
					task.wait(0.45)
					continue
				end

				local isOnLook = Finder.IsOnDot(Humanoid, closest)

				if isOnLook then
					Path.StartFollowing(Humanoid, closest.RootPart)
				else
					Path.LeaveFollowing()
				end

				task.wait()
			end
		end)
	end
end
