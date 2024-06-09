local RunService = game:GetService("RunService")

local AI = {}

AI.AnimationsTable = nil

function AI.Start()
	do --> começa a buscar o humanoid
		if script.Parent:IsA("Actor") then
			local Path = require(script.Path)
			local Finder = require(script.Finder)

			local NPC: Model = script:FindFirstAncestorOfClass("Model")

			local Humanoid: Humanoid = NPC:FindFirstChildWhichIsA("Humanoid", true)

			local Animator = Humanoid:FindFirstChildWhichIsA("Animator") :: Animator

			local AnimationsFolder = game.ReplicatedStorage:WaitForChild("Animations")

			 AI.AnimationsTable = {
				["Melee"] = {
					["Hit"] = {
						[1] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["1"]:Clone()),
						[2] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["2"]:Clone()),
						[3] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["3"]:Clone()),
						[4] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["4"]:Clone()),
					},
					["Ground Slam"] = Animator:LoadAnimation(AnimationsFolder.Melee["Ground Slam"]:Clone()),
					["Block"] = Animator:LoadAnimation(AnimationsFolder.Melee["Block"]:Clone()),
				}

			}

			Path.Start(Humanoid)
			Finder.Start(Path)



			local AlignOrientation = Instance.new("AlignOrientation", Humanoid.RootPart)
			AlignOrientation.AlignType = Enum.AlignType.PrimaryAxisLookAt
			AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			AlignOrientation.Attachment0 = Humanoid.RootPart:FindFirstChild("Align", true)
			AlignOrientation.Responsiveness = 45

			AlignOrientation.Enabled = false

			local Connection
			Connection = RunService.Heartbeat:ConnectParallel(function()
				if Humanoid.Health <= 0 then
					Connection:Disconnect()
					return
				end

				local closest = Finder.GetClosestHumanoid(Humanoid, true, 15)
				if not closest then
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
		end
	end
end

AI.Start()

return AI
