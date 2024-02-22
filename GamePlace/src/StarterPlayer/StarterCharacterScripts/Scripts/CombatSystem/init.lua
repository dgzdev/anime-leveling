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

if not (Players:GetAttribute("Loaded")) then
	Players:GetAttributeChangedSignal("Loaded"):Wait()
end

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
		local sounds = SoundService:WaitForChild("Attack"):WaitForChild(weaponType):GetChildren()

		if #anims > 0 then
			attack = math.clamp(attack, 1, #anims)
			local anim = anims[attack]
			local Animator = Humanoid:WaitForChild("Animator") :: Animator
			local AttackAnim = Animator:LoadAnimation(anim)

			AttackAnim.Priority = Enum.AnimationPriority.Action
			AttackAnim:Play()
		end
		if #sounds > 0 then
			attack = math.clamp(attack, 1, #sounds)
			local sound = sounds[attack]
			local s = sound:Clone() :: Sound
			s.Parent = Character:WaitForChild("Head")
			s.RollOffMaxDistance = 0
			s.RollOffMaxDistance = 30
			s.RollOffMode = Enum.RollOffMode.Linear

			if not s.IsLoaded then
				s.Loaded:Wait()
			end

			s:Play()
			Debris:AddItem(s, s.TimeLength)
		end
		if #anims == 0 and #sounds == 0 then
			return warn("No animations or sounds found for weapon type: " .. weaponType)
		end

		if (attack == #anims) or (attack == #sounds) then
			attack = 1
		else
			attack = attack + 1
		end
	end
end

function CombatSystem:ChangeDefenseStatus(state: true | false)
	local WeaponType = Player:GetAttribute("WeaponType")
	if state == true then
		local anim = Animations:WaitForChild(WeaponType):WaitForChild("Block") :: Animation
		local Animator = Humanoid:WaitForChild("Animator") :: Animator

		local BlockAnim = Animator:LoadAnimation(anim)
		BlockAnim.Priority = Enum.AnimationPriority.Action
		BlockAnim.Looped = true
		BlockAnim:Play(0.15)
	end
	if state == false then
		local Animator = Humanoid:WaitForChild("Animator") :: Animator
		for _, Value in ipairs(Animator:GetPlayingAnimationTracks()) do
			if Value.Name == "Block" then
				Value:Stop(0.5)
			end
		end
	end
end

local DefendLoadedAnimation = nil
function CombatSystem:Defend(state: "Start" | "End")
	if Humanoid.Health > 0 then
		-- Defend logic
		Character:GetAttributeChangedSignal("Defending"):Connect(function()
			self:ChangeDefenseStatus(Character:GetAttribute("Defending"))
		end)

		local properties = Combat:InvokeServer("Defend", state)
		if not properties then
			return
		end
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
		CombatSystem:Defend("Start")
	elseif state == Enum.UserInputState.End then
		CombatSystem:Defend("End")
	end
end, true, table.unpack(DefendButtons))

return CombatSystem
