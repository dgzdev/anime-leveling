local Ragdoll = {}

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerEvents = ReplicatedStorage:WaitForChild("Player")

function OnRagdoll(Ragdolled)
	if Ragdolled then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

PlayerEvents.Ragdoll.OnClientEvent:Connect(OnRagdoll)

function Ragdoll:Init()
	OnRagdoll(false)
end

return Ragdoll
