local ContentProvider = game:GetService("ContentProvider")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local CombatSystem = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local AttackButtons = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Gamepad1 }
local DefendButtons = { Enum.UserInputType.MouseButton2, Enum.UserInputType.Gamepad2 }

local Combat = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat") :: RemoteFunction
local Animations = ReplicatedStorage:WaitForChild("Animations")

local attack = 1
local Cooldown = tick()

ContentProvider:PreloadAsync(Animations:GetDescendants())
ContentProvider:PreloadAsync(SoundService:WaitForChild("Attack"):GetDescendants())
ContentProvider:PreloadAsync(SoundService:WaitForChild("SFX"):GetDescendants())

print("loaded")

function CombatSystem:Attack()
	if Humanoid.Health > 0 then
		-- Attack logic

		Cooldown = tick() + 1

		local properties = Combat:InvokeServer("Attack")
		if not properties then
			return
		end
		local weaponType = properties.Type

		local anims = Animations:WaitForChild(weaponType):WaitForChild("Hit"):GetChildren()
		local sounds = SoundService:WaitForChild("Attack"):WaitForChild("Sword"):GetChildren()

		attack = math.clamp(attack, 1, #anims)

		local anim = anims[attack]
		local sound = sounds[attack]

		local Animator = Humanoid:WaitForChild("Animator") :: Animator
		local AttackAnim = Animator:LoadAnimation(anim)

		local s = sound:Clone() :: Sound
		s.Parent = Character:WaitForChild("Head")
		s.RollOffMaxDistance = 0
		s.RollOffMaxDistance = 30
		s.RollOffMode = Enum.RollOffMode.Inverse

		repeat
			task.wait()
		until s.IsLoaded == true

		s:Play()
		Debris:AddItem(s, 1.5)

		AttackAnim.Priority = Enum.AnimationPriority.Action
		AttackAnim:Play()

		if attack == #anims then
			attack = 1
		else
			attack = attack + 1
		end
	end
end

function CombatSystem:Defend()
	if Humanoid.Health > 0 then
		-- Defend logic
		Combat:InvokeServer("Defend")
	end
end

function CombatSystem:Die()
	if Humanoid.Health <= 0 then
		-- Die logic
	end
end

ContextActionService:BindAction("Attack", function(action, state, input)
	if tick() < Cooldown then
		return
	end
	if state == Enum.UserInputState.Begin then
		CombatSystem:Attack()
	end
end, true, table.unpack(AttackButtons))

ContextActionService:BindAction("Defend", function(action, state, input)
	if state == Enum.UserInputState.Begin then
		CombatSystem:Defend()
	end
end, true, table.unpack(DefendButtons))

return CombatSystem
