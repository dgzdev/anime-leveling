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

local Animations = ReplicatedStorage:WaitForChild("Animations")

local PlayingAnimation: AnimationTrack

local Cooldowns = {
	["FlashStrike"] = 0,
}

local SFX = require(ReplicatedStorage.Modules.SFX)

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

local Sword = {
	[Enum.UserInputType.MouseButton1] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
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

			if CheckCooldown("Slash") then
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

			local Combos = Animations:WaitForChild("Sword"):WaitForChild("Hit"):GetChildren()
			table.sort(Combos, function(a, b)
				return a.Name < b.Name
			end)

			local ComboAnimation: Animation = Combos[_G.Combo]

			if PlayingAnimation then
				PlayingAnimation:Stop()
			end

			SFX:Create(RootPart, "Slash", 0, 60, false)

			PlayingAnimation = Animator:LoadAnimation(ComboAnimation)
			SetCooldown("Slash", PlayingAnimation.Length)

			local DelayTime = 0.15
			if _G.Combo == 1 then
				DelayTime = 0.3
			end

			Humanoid:SetAttribute("SlideGetUp", true)
			Humanoid:SetAttribute("SlideGetUp", false)

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
		name = "Slash",
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

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if CheckCooldown("Defense") then
				return
			end

			if Character:GetAttribute("Stun") then
				return
			end
		end,
		name = "Defense",
	},
}

function Sword.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return Sword
