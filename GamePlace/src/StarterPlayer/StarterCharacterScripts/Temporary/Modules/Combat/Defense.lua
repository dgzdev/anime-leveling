local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Combat = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat") :: RemoteFunction

local Defense = {}

local CachedAnim: Animation

function Defense:ChangeState(state: true | false)
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:WaitForChild("Animator") :: Animator

	local wSpeed = StarterPlayer.CharacterWalkSpeed
	local jPower = StarterPlayer.CharacterJumpPower

	Humanoid.WalkSpeed = state and (wSpeed * 0.5) or wSpeed
	Humanoid.JumpPower = state and (jPower * 0.5) or jPower

	if state == true then
		Animator:LoadAnimation(CachedAnim):Play(0.15)
	elseif state == false then
		for _, Animation: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
			if Animation.Name == CachedAnim.Name then
				Animation:Stop(0.15)
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

function Defense:ChangeDefenseState(state: string)
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	if Character:GetAttribute("Stun") then
		return
	end

	if Character:GetAttribute("Attacking") then
		return
	end

	if Humanoid.Health > 0 then
		local properties = Combat:InvokeServer("Defend", state)
		if not properties then
			return
		end
	end
end

function Defense.Init()
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()

	Defense:CreateCache()

	Player:GetAttributeChangedSignal("WeaponType"):Connect(function()
		Defense:CreateCache()
	end)

	Player.CharacterAdded:Connect(function(character)
		Character:GetAttributeChangedSignal("Defending"):Connect(function()
			Defense:ChangeState(Character:GetAttribute("Defending"))
		end)
	end)

	Character:GetAttributeChangedSignal("Defending"):Connect(function()
		Defense:ChangeState(Character:GetAttribute("Defending"))
	end)
end

return Defense
