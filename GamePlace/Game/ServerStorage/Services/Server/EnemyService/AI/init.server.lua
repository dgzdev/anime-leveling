local RunService = game:GetService("RunService")

local Path = require(script.Path)
local Finder = require(script.Finder)

do --> começa a buscar o humanoid
	if script.Parent:IsA("Actor") then
		local NPC: Model = script:FindFirstAncestorOfClass("Model")

		local Humanoid: Humanoid = NPC:FindFirstChildWhichIsA("Humanoid", true)

		local AlignOrientation = Instance.new("AlignOrientation", Humanoid.RootPart)
		AlignOrientation.AlignType = Enum.AlignType.PrimaryAxisLookAt
		AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		AlignOrientation.Attachment0 = Humanoid.RootPart:FindFirstChild("Align", true)
		AlignOrientation.Responsiveness = 45

		AlignOrientation.Enabled = false

		task.spawn(function()
			RunService.Heartbeat:ConnectParallel(function()
				local closest = Finder.GetClosestHumanoid(Humanoid, true, 15)
				if not closest then
					task.wait(0.45)
					return
				end

				task.desynchronize()

				local isOnLook = Finder.IsOnDot(Humanoid, closest)
				

				if isOnLook and (Humanoid.RootPart.Position - closest.RootPart.Position).Magnitude < 20 then
					Path.StartFollowing(Humanoid, closest.RootPart)
				else
					Path.LeaveFollowing()
				end

				task.wait()
			end)
			--while true do
			--	local closest = Finder.GetClosestHumanoid(Humanoid, true, 15)
			--	if not closest then
			--		task.wait(0.45)
			--		continue
			--	end
--
			--	local isOnLook = Finder.IsOnDot(Humanoid, closest)
--
			--	if isOnLook then
			--		Path.StartFollowing(Humanoid, closest.RootPart)
			--	else
			--		Path.LeaveFollowing()
			--	end
--
			--	task.wait()
			--end
		end)
	end
end
