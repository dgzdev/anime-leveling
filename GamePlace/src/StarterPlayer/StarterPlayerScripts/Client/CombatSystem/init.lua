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

function CombatSystem:Attack()
	if Humanoid.Health > 0 then
		if tick() < Cooldown then
			return
		end

		-- Attack logic
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
		Cooldown = tick() + AttackAnim.Length + 0.8

		local s = sound:Clone() :: Sound
		s.Parent = Character:WaitForChild("HumanoidRootPart")
		s.RollOffMaxDistance = 0
		s.RollOffMaxDistance = 30
		s.RollOffMode = Enum.RollOffMode.Inverse
		s:Play()
		Debris:AddItem(s, s.TimeLength + 0.1)

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