local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeaponService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Default = require(script.Parent.Parent.Default)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart: BasePart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local PlayerGui = Player:WaitForChild("PlayerGui")

local CombatGui = PlayerGui:WaitForChild("PlayerHud")
local Background: Frame = CombatGui:WaitForChild("Background"):WaitForChild("CombatGui")

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local Animations = ReplicatedStorage:WaitForChild("Animations")

local PlayingAnimation: AnimationTrack | nil
local HoldingTime = 0

local Cooldowns = {
	["FlashStrike"] = 0,
}

local function SetCooldown(name: string, cooldown: number)
	Cooldowns[name] = tick() + cooldown
	local Frame: Frame = Background:WaitForChild("Slots"):FindFirstChild(name)

	if Frame then
		task.spawn(function()
			local btn = Frame:FindFirstChild("Button", true)
			btn.BackgroundColor3 = Color3.fromRGB(241, 127, 129)
			local anim =
				TweenService:Create(btn, TweenInfo.new(cooldown), { BackgroundColor3 = Color3.new(0.9, 0.9, 0.9) })
			anim:Play()
			anim.Completed:Wait()
		end)
	end
end

local function CheckCooldown(name: string)
	if Cooldowns[name] then
		if tick() < Cooldowns[name] then
			return true
		end
	end
	return false
end

_G.Combo = 1

local Melee = {
	[Enum.UserInputType.MouseButton1] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
				HoldingTime = 0
				RootPart.Anchored = false
				return
			end

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if PlayingAnimation then
				if PlayingAnimation.IsPlaying then
					return
				end
			end

			if CheckCooldown("Punch") then
				return
			end

			if Humanoid.WalkSpeed == 0 then
				return
			end

			if RootPart.Anchored then
				return
			end

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			if Character:GetAttribute("Stun") then
				return
			end

			local Combos = Animations:WaitForChild("Melee"):WaitForChild("Hit"):GetChildren()
			table.sort(Combos, function(a, b)
				return a.Name < b.Name
			end)

			local ComboAnimation: Animation = Combos[_G.Combo]

			SFX:Create(RootPart, "MeleeSwing", 0, 60, false)
			if PlayingAnimation then
				PlayingAnimation:Stop()
			end

			PlayingAnimation = Animator:LoadAnimation(ComboAnimation)
			SetCooldown("Punch", PlayingAnimation.Length)

			local DelayTime = 0.15
			if _G.MeleeCombo == 1 then
				DelayTime = 0.3
			end

			task.spawn(function()
				WeaponService:WeaponInput("Attack", Enum.UserInputState.End, {
					Position = RootPart.CFrame,
					Combo = _G.Combo,
					Combos = #Combos,
				})
			end)

			PlayingAnimation:Play(DelayTime)

			_G.Combo += 1

			if _G.Combo > #Combos then
				_G.Combo = 1
			end
		end,
		name = "Punch",
	},
	[Enum.UserInputType.MouseButton2] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
				RootPart.Anchored = false
				return
			end

			if Character:GetAttribute("Stun") then
				return
			end

			if inputstate == Enum.UserInputState.Begin then
				if CheckCooldown("Block") then
					return
				end
				if PlayingAnimation then
					if PlayingAnimation.IsPlaying then
						return
					end
				end

				if Humanoid.Health <= 0 then
					return
				end

				if Character:GetAttribute("Stun") then
					return
				end

				task.spawn(function()
					WeaponService:WeaponInput("Defense", Enum.UserInputState.Begin, {
						Position = RootPart.CFrame,
					})
				end)

				PlayingAnimation = Animator:LoadAnimation(Animations:WaitForChild("Melee"):WaitForChild("Block"))
				PlayingAnimation:Play(0.2)

				SetCooldown("Block", 0.75)
			end
			if inputstate == Enum.UserInputState.End then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.3)

					task.spawn(function()
						WeaponService:WeaponInput("Defense", Enum.UserInputState.End, {
							Position = RootPart.CFrame,
						})
					end)

					PlayingAnimation = nil
				end
			end
		end,
		name = "Block",
	},
	[Enum.KeyCode.Z] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
				HoldingTime = 0
				RootPart.Anchored = false
				return
			end

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if PlayingAnimation then
				if PlayingAnimation.IsPlaying then
					return
				end
			end

			if CheckCooldown("Ground Slam") then
				return
			end

			if Humanoid.WalkSpeed == 0 then
				return
			end

			if RootPart.Anchored then
				return
			end

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			if Character:GetAttribute("Stun") then
				return
			end

			RootPart.Anchored = true

			SetCooldown("Ground Slam", 3)

			PlayingAnimation = Animator:LoadAnimation(Animations:WaitForChild("Melee"):WaitForChild("Ground Slam"))
			PlayingAnimation:Play()
			PlayingAnimation:GetMarkerReachedSignal("end"):Once(function()
				SFX:Create(RootPart, "Ground-Slam", 10, 80, false)
				PlayingAnimation:AdjustSpeed(0)
				
				task.spawn(function()
					WeaponService:WeaponInput("Ground Slam", Enum.UserInputState.End, {
						Position = RootPart.CFrame,
					})
				end)
				
			end)

	
			task.wait(2)

			PlayingAnimation:Stop(0.3)
			RootPart.Anchored = false
		end,
		name = "Ground Slam",
	},
	[Enum.KeyCode.X] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
				HoldingTime = 0
				RootPart.Anchored = false
				return
			end

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if PlayingAnimation then
				if PlayingAnimation.IsPlaying then
					return
				end
			end

			if CheckCooldown("Strong Punch") then
				return
			end

			if Humanoid.WalkSpeed == 0 then
				return
			end

			if RootPart.Anchored then
				return
			end

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			if Character:GetAttribute("Stun") then
				return
			end

			RootPart.Anchored = true

			SetCooldown("Strong Punch", 2)

			task.spawn(function()
				WeaponService:WeaponInput("Strong Punch", Enum.UserInputState.End, {
					Position = RootPart.CFrame,
				})
			end)

			task.wait(1)

			RootPart.Anchored = false
		end,
		name = "Strong Punch",
	},
}

function Melee.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return Melee
