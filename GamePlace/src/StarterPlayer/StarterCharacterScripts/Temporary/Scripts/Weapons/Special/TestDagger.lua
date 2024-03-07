-- Lightning Strike
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local WeaponService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Combat = ReplicatedStorage.Events.Combat :: RemoteFunction

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart: BasePart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local PlayerGui = Player:WaitForChild("PlayerGui")

local CombatGui = PlayerGui:WaitForChild("PlayerHud")
local Background: Frame = CombatGui:WaitForChild("Background"):WaitForChild("CombatGui")

local PlayingAnimation: AnimationTrack
local HoldingTime = 0

local Cooldowns = {
	["FlashStrike"] = 0,
}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
end

local Camera = Workspace.CurrentCamera

local function Lockmouse()
	Character:PivotTo(
		CFrame.lookAt(
			RootPart.Position,
			RootPart.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
		)
	)
end
local function SetCooldown(name: string, cooldown: number)
	Cooldowns[name] = tick() + cooldown
	local Frame: Frame = Background:FindFirstChild(name)

	if Frame then
		Frame.BackgroundTransparency = 0.65
		task.spawn(function()
			local Ready: ImageLabel = Frame:WaitForChild("Ready")
			Ready.Visible = false

			local anim = TweenService:Create(Frame, TweenInfo.new(cooldown), { BackgroundTransparency = 0 })
			anim:Play()
			anim.Completed:Wait()

			Ready.Visible = true
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

local TestDagger = {
	[Enum.KeyCode.Z] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Cancel then
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end
				RunService:UnbindFromRenderStep("Lockmouse")
				HoldingTime = 0
				RootPart.Anchored = false
				return
			end

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			if CheckCooldown("LStrike") then
				return
			end

			SetCooldown("LStrike", 1)

			task.spawn(function()
				WeaponService:WeaponInput("LStrike", Enum.UserInputState.End, {
					Position = RootPart.CFrame,
				})
			end)

			local Animation =
				ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Sword"):WaitForChild("Hit"):WaitForChild("2")

			if PlayingAnimation then
				PlayingAnimation:Stop()
			end

			PlayingAnimation = Animator:LoadAnimation(Animation)
			PlayingAnimation:AdjustSpeed(0.25)
			PlayingAnimation:Play(0.15)
		end,
		name = "LStrike",
	},
}

function TestDagger.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return TestDagger
