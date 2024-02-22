local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Defense = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local CachedAnim: AnimationTrack

function Defense:ChangeState(state: true | false)
	if state == true then
		CachedAnim:Play(0.15)
	elseif state == false then
		CachedAnim:Stop(0.15)
	end
end

function Defense:CreateCache()
	local WeaponType = Player:GetAttribute("WeaponType")
	local anim =
		ReplicatedStorage:WaitForChild("Animations"):WaitForChild(WeaponType):WaitForChild("Block") :: Animation

	local BlockAnim = Animator:LoadAnimation(anim)
	BlockAnim.Priority = Enum.AnimationPriority.Action4
	BlockAnim.Looped = true

	CachedAnim = BlockAnim
end

function Defense:Init()
	self:CreateCache()

	Character:GetAttributeChangedSignal("Defending"):Connect(function()
		self:ChangeState(Character:GetAttribute("Defending"))
	end)

	Player:GetAttributeChangedSignal("WeaponType"):Connect(function()
		self:CreateCache()
	end)
end

return Defense
