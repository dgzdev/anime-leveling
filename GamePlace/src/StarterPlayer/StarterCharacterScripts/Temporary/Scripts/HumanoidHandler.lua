local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HumanoidHandler = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")
local Animator: Animator = Humanoid:WaitForChild("Animator")

local VFX = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("VFX"))

function HumanoidHandler:OnLand()
	VFX:ApplyParticle(Character, "Fell", nil, Vector3.new(0, -2, 0), true)
	local Animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Landed")
	local AnimationTrack = Animator:LoadAnimation(Animation)
	AnimationTrack:Play(0.15)
end

function HumanoidHandler:OnFallingDown()
	VFX:ApplyParticle(Character, "Falling", nil, nil, true)
end

function HumanoidHandler:Init()
	Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			self:OnLand()
		end
		if new == Enum.HumanoidStateType.Freefall then
			self:OnFallingDown()
		end
	end)
end

return HumanoidHandler
