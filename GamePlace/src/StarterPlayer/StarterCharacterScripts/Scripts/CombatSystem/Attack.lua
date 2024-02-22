local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Attack = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local CacheAnims: { AnimationTrack } = {}
local CacheSounds: { Sound } = {}

_G.Attack = 1
_G.Sound = 1

function Attack:Run()
	-- == Attack logic == --
	if #CacheAnims > 0 then
		local anim = CacheAnims[_G.Attack]
		anim.Priority = Enum.AnimationPriority.Action

		local speed = anim:GetAttribute("Speed") or 1
		local weight = anim:GetAttribute("Weight") or 1
		local fadeTime = anim:GetAttribute("FadeTime") or 0.1

		local sound = CacheSounds[_G.Sound]:Clone()
		sound.Parent = Character:WaitForChild("HumanoidRootPart")
		Debris:AddItem(sound, sound.TimeLength)
		sound:Play()

		_G.Attack += 1
		if _G.Attack >= #CacheAnims then
			_G.Attack = 1
		end
		_G.Sound += 1
		if _G.Sound >= #CacheSounds then
			_G.Sound = 1
		end

		anim:Play(fadeTime, weight, speed)
		anim.Ended:Wait()
	end
end

function Attack:CreateCache()
	local weaponType = Player:GetAttribute("WeaponType")
	local anims = ReplicatedStorage.Animations:WaitForChild(weaponType):WaitForChild("Hit"):GetChildren()
	local sounds = SoundService:WaitForChild("Attack"):WaitForChild(weaponType):GetChildren()

	for _, anim: Animation in ipairs(anims) do
		local animName = anim.Name
		local animInstance = Animator:LoadAnimation(anim)
		animInstance.Priority = Enum.AnimationPriority.Action4

		for name, value in pairs(anim:GetAttributes()) do
			animInstance:SetAttribute(name, value)
		end

		CacheAnims[animName] = animInstance
	end
	for _, sound in ipairs(sounds) do
		local soundName = sound.Name
		local soundInstance = sound:Clone()
		soundInstance.RollOffMaxDistance = 0
		soundInstance.RollOffMaxDistance = 30
		soundInstance:SetAttribute("Ignore", true)
		soundInstance.RollOffMode = Enum.RollOffMode.Linear
		CacheSounds[soundName] = soundInstance
	end
end

function Attack:Init()
	Attack:CreateCache()

	Player:GetAttributeChangedSignal("WeaponType"):Connect(Attack.CreateCache)

	task.spawn(function()
		while true do
			if Workspace:GetAttribute("Attacking") then
				print("attacking")
				Attack:Run()
			else
				Workspace:GetAttributeChangedSignal("Attacking"):Wait()
			end
			task.wait()
		end
	end)
end

return Attack
