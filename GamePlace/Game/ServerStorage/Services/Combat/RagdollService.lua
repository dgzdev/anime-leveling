local Knit = require(game.ReplicatedStorage.Packages.Knit)

local RagdollService = Knit.CreateService({
	Name = "RagdollService",
	Client = {},
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Ragdoll)

function RagdollService:Ragdoll(Character: Model, time: number?)
	Ragdoll.RagdollCharacter(Character)

	local Player = Players:GetPlayerFromCharacter(Character)

	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

	if not Player then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end

	if time then
		task.delay(time, function()
			Ragdoll.UnRagdollCharacter(Character)

			if not Player then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
end

function RagdollService:UnRagdoll(Character: Model)
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	Ragdoll.UnRagdollCharacter(Character)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local Humanoid = Character:WaitForChild("Humanoid")

		Character.HumanoidRootPart.AncestryChanged:Connect(function()
			if not Character:FindFirstChild("HumanoidRootPart") then
				task.wait(Players.RespawnTime)
				if Player:IsDescendantOf(Players) then
					--Player:LoadCharacter()
				end
			end
		end)

		Humanoid.BreakJointsOnDeath = false
		Humanoid.RequiresNeck = false
		Humanoid.Died:Connect(function()
			--print("morreu4")
			Ragdoll.RagdollCharacter(Character)
		end)
	end)
end)

return RagdollService
