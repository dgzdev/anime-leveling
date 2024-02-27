local Ragdoll = {}

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local PlayerEvents = ReplicatedStorage:WaitForChild("Player")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
pcall(function()
	StarterGui:SetCore("ResetButtonCallback", true)
end)

function OnRagdoll(Ragdolled)
	if Ragdolled then
		Humanoid:UnequipTools()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCore("ResetButtonCallback", false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	else
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		StarterGui:SetCore("ResetButtonCallback", true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

PlayerEvents.Ragdoll.OnClientEvent:Connect(OnRagdoll)

function Ragdoll:Init() end

return Ragdoll
