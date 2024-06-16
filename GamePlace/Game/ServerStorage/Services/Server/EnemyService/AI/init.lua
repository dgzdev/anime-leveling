local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local AI = {}

AI.AnimationsTable = nil

local ToolsFolder = game.ReplicatedStorage.Models.Tools

function AI.Start()
	do --> começa a buscar o humanoid
		if script.Parent:IsA("Actor") then
			local Path = require(script.Path)
			local Finder = require(script.Finder)
			
			local EquipService = Knit.GetService("EquipService")
			
			local NPC: Model = script:FindFirstAncestorOfClass("Model")
			local Humanoid: Humanoid = NPC:FindFirstChildWhichIsA("Humanoid", true)
			local Animator = Humanoid:FindFirstChildWhichIsA("Animator") :: Animator

			local weaponName = NPC:GetAttribute("Weapon") or "Fists"


			local Weapon: Tool = ToolsFolder:FindFirstChild(weaponName) or ToolsFolder:WaitForChild("Fists", 10)

			if Weapon then
				Weapon = Weapon:Clone()
				Weapon:SetAttribute("Class", "Weapon")
				Weapon.Parent = NPC
			end

			local HittedEvent = Instance.new("BindableEvent", script)
			HittedEvent.Name = "Hitted"

			EquipService:EquipItem(NPC)

			Humanoid:SetAttribute("WeaponType", Weapon:GetAttribute("Type") or "Melee")
			Humanoid:SetAttribute("WeaponEquipped", true)

			CollectionService:AddTag(NPC, "Enemies")

			Humanoid:SetAttribute("ComboCounter", 0)
			Humanoid:SetAttribute("MaxPosture", 100)
			Humanoid:SetAttribute("Posture", 0)

			local AnimationsFolder = game.ReplicatedStorage:WaitForChild("Animations")
			
			task.wait()
			
			AI.AnimationsTable = {
				["Melee"] = {
					["Hit"] = {
						[1] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["0"]:Clone()),
						[2] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["1"]:Clone()),
						[3] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["2"]:Clone()),
						[4] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["3"]:Clone()),
					},
					["Ground Slam"] = Animator:LoadAnimation(AnimationsFolder.Melee["Ground Slam"]:Clone()),
					["Block"] = Animator:LoadAnimation(AnimationsFolder.Melee["Block"]:Clone()),
				},
			}

			Path.Start(Humanoid)
			Finder.Start(Path)

			local AlignOrientation = Instance.new("AlignOrientation", Humanoid.RootPart)
			AlignOrientation.Name = "LookPlayer"
			AlignOrientation.AlignType = Enum.AlignType.PrimaryAxisLookAt
			AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			AlignOrientation.Attachment0 = Humanoid.RootPart:WaitForChild("RootAttachment")
			AlignOrientation.Responsiveness = 120
			AlignOrientation.CFrame = Humanoid.RootPart.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)

			local Connection
			Connection = RunService.Heartbeat:ConnectParallel(function()
				if Humanoid.Health <= 0 then
					task.synchronize()
					Connection:Disconnect()
					task.desynchronize()
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
					if NPC:FindFirstChild("Allies") then
						for i,v : ObjectValue in pairs(NPC:FindFirstChild("Allies"):GetChildren()) do
							if v.Value == closest.Parent then
								Path.TargetisAlly = true
								Path.StartFollowing(Humanoid, closest.RootPart)
							end
						end
					end
				end

				task.wait()
			end)
		end
	end
end

AI.Start()

return AI
