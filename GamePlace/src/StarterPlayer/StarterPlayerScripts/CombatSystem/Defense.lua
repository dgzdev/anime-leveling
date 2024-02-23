local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Defense = {}

local CachedAnim: Animation

function Defense:ChangeState(state: true | false)
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:WaitForChild("Animator") :: Animator

	if state == true then
		Animator:LoadAnimation(CachedAnim):Play(0.15)
	elseif state == false then
		for _, Animation: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
			if Animation.Name == CachedAnim.Name then
				Animation:Stop(0.15)
				break
			end
		end
	end
end

function Defense:CreateCache()
	local Player = Players.LocalPlayer
	local WeaponType = Player:GetAttribute("WeaponType")
	local anim =
		ReplicatedStorage:WaitForChild("Animations"):WaitForChild(WeaponType):WaitForChild("Block") :: Animation
	CachedAnim = anim
end

function Defense:Init()
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()

	self:CreateCache()

	Player:GetAttributeChangedSignal("WeaponType"):Connect(function()
		self:CreateCache()
	end)

	Player.CharacterAdded:Connect(function(character)
		Character:GetAttributeChangedSignal("Defending"):Connect(function()
			self:ChangeState(Character:GetAttribute("Defending"))
		end)
	end)

	Character:GetAttributeChangedSignal("Defending"):Connect(function()
		self:ChangeState(Character:GetAttribute("Defending"))
	end)
end

return Defense
