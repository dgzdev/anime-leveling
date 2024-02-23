local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Attack = {}

local CacheAnims: { AnimationTrack } = {}
local CacheSounds: { Sound } = {}

local CombatRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat") :: RemoteFunction

_G.Attack = 1
_G.Sound = 1

function Attack:Run()
	print("atk")
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:WaitForChild("Animator") :: Animator

	-- == Attack logic == --
	if #CacheAnims > 0 then
		if _G.Attack > #CacheAnims then
			_G.Attack = 1
		end
		if _G.Sound > #CacheSounds then
			_G.Sound = 1
		end

		local anim = Animator:LoadAnimation(CacheAnims[_G.Attack])
		anim.Priority = Enum.AnimationPriority.Action

		print(_G.Attack, CacheAnims)

		local speed = anim:GetAttribute("Speed") or 1
		local weight = anim:GetAttribute("Weight") or 1
		local fadeTime = anim:GetAttribute("FadeTime") or 0

		local sound = CacheSounds[_G.Sound]:Clone()
		sound.Parent = Character:WaitForChild("HumanoidRootPart")
		Debris:AddItem(sound, sound.TimeLength)
		sound:Play()

		CombatRemote:InvokeServer("Attack", {
			Combo = _G.Attack,
			Combos = #CacheAnims,
		})

		anim:Play(fadeTime, weight, speed)
		anim.Ended:Wait()

		_G.Sound += 1
		_G.Attack += 1
	end
end

function Attack:CreateCache()
	local Player = Players.LocalPlayer

	table.clear(CacheAnims)
	table.clear(CacheSounds)

	local weaponType = Player:GetAttribute("WeaponType")
	local anims = ReplicatedStorage.Animations:WaitForChild(weaponType):WaitForChild("Hit"):GetChildren()
	local sounds = SoundService:WaitForChild("Attack"):WaitForChild(weaponType):GetChildren()

	for _, anim: Animation in ipairs(anims) do
		table.insert(CacheAnims, anim)
	end
	for _, sound in ipairs(sounds) do
		local soundInstance = sound:Clone()
		soundInstance.RollOffMaxDistance = 0
		soundInstance.RollOffMaxDistance = 30
		soundInstance:SetAttribute("Ignore", true)
		soundInstance.RollOffMode = Enum.RollOffMode.Linear

		table.insert(CacheSounds, soundInstance)
	end
end

function Attack.Init()
	local Player = Players.LocalPlayer

	Attack:CreateCache()

	Player:GetAttributeChangedSignal("WeaponType"):Connect(Attack.CreateCache)
	Player.CharacterAdded:Connect(Attack.CreateCache)

	print("iniciou")

	task.spawn(function()
		while true do
			if Workspace:GetAttribute("Attacking") then
				Attack:Run()
				print("passo")
			else
				Workspace:GetAttributeChangedSignal("Attacking"):Wait()
			end
			task.wait()
		end
	end)
end

return Attack
