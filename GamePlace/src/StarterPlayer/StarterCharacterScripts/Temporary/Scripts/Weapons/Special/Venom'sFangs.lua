-- Lightning Strike
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeaponService
local ShakerController

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

local Cooldowns = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in (model:GetDescendants()) do
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
		name = "Venom Dash",
	},
	[Enum.KeyCode.R] = {
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

			if Humanoid.Health <= 0 then
				return
			end

			if inputstate == Enum.UserInputState.Begin then
				if CheckCooldown("Venom Palm") then
					return
				end

				--> Animação de segurar
				local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
					:WaitForChild("FlashStrike Hold")
				PlayingAnimation = Animator:LoadAnimation(Animation)

				PlayingAnimation:Play(0.15)
				PlayingAnimation:GetMarkerReachedSignal("HoldEnd"):Connect(function()
					PlayingAnimation:AdjustSpeed(0)
				end)

				RootPart.Anchored = true

				task.spawn(function()
					while true do
						HoldingTime += 0.1
						if PlayingAnimation.IsPlaying == false then
							break
						end
						task.wait(0.1)
					end
				end)
			elseif inputstate == Enum.UserInputState.End then
				--> Animação de soltar
				if PlayingAnimation then
					PlayingAnimation:Stop(0.15)
				end

				RootPart.Anchored = false

				if HoldingTime > 0.45 then
					task.spawn(function()
						WeaponService:WeaponInput("Venom Palm", Enum.UserInputState.End, {
							Position = RootPart.CFrame,
						})
					end)

					SetCooldown("Venom Palm", 3)
					SFX:Create(RootPart, "Death")
				end

				HoldingTime = 0
			end
		end,
		name = "Venom Palm",
	},

	[Enum.KeyCode.X] = {
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

			if Humanoid.Health <= 0 then
				return
			end

			if CheckCooldown("Dual Barrage") then
				return
			end

			if inputstate == Enum.UserInputState.Begin then
				--> Animação de segurar
				local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
					:WaitForChild("FlashStrike Hold")
				PlayingAnimation = Animator:LoadAnimation(Animation)
				PlayingAnimation:Play(0.15)
				PlayingAnimation:GetMarkerReachedSignal("HoldEnd"):Connect(function()
					PlayingAnimation:AdjustSpeed(0)
				end)

				task.spawn(function()
					while true do
						HoldingTime += 0.1
						if PlayingAnimation then
							if PlayingAnimation.IsPlaying == false then
								break
							end
						end

						task.wait(0.1)
					end
				end)
				RootPart.Anchored = true
			elseif inputstate == Enum.UserInputState.End then
				RootPart.Anchored = false

				if HoldingTime > 0.45 then
					PlayingAnimation:Stop(0)
					SetCooldown("Dual Barrage", 10) -- > 10 segundos de cooldown

					--> animação de ataque
					local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
						:FindFirstChild("Dagger")
						:FindFirstChild("Skills")
						:FindFirstChild("Combo")

					PlayingAnimation = Animator:LoadAnimation(Animation)
					PlayingAnimation:Play()

					PlayingAnimation:GetMarkerReachedSignal("teleport"):Connect(function()
						task.spawn(function()
							WeaponService:WeaponInput("VenomDash", Enum.UserInputState.Begin, {
								Position = RootPart.CFrame,
							})
						end)
					end)

					comboTicks = 0

					task.spawn(function()
						for _i = 1, 5, 1 do
							task.wait(0.3)

							task.spawn(function()
								WeaponService:WeaponInput("DualBarrage", Enum.UserInputState.Begin, {
									Position = RootPart.CFrame,
								})
							end)

							comboTicks += 1
						end
					end)
				else
					if PlayingAnimation then
						PlayingAnimation:Stop(0.15)
					end
				end
			end
		end,
		name = "Dual Barrage",
	},
}

function TestDagger.Start()
	WeaponService = Knit.GetService("WeaponService")
	ShakerController = Knit.GetController("ShakerController")
end

return TestDagger
