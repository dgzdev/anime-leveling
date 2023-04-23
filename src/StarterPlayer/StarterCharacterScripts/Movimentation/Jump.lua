local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

--// Variables
local Players = game:GetService("Players")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Jump = {}

function Jump:Start()
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(0, 40000, 0)
	bodyVelocity.Velocity = Vector3.new(0, 60, 0)
    bodyVelocity.Parent = Character:WaitForChild("HumanoidRootPart")
    Debris:AddItem(bodyVelocity, 0.1)
end

return Jump