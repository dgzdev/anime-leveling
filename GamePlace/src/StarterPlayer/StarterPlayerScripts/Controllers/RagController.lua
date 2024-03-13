local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Ragdoll = Knit.CreateController({
	Name = "Ragdoll",
})

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerEvents = ReplicatedStorage:WaitForChild("Player")

function OnRagdoll(Ragdolled)
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")

	if not Humanoid then
		return
	end

	if Ragdolled then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function Ragdoll:KnitStart()
	coroutine.wrap(function()
		Player.CharacterAdded:Connect(function(character)
			OnRagdoll(false)
		end)

		PlayerEvents.Ragdoll.OnClientEvent:Connect(OnRagdoll)
	end)
end

return Ragdoll
