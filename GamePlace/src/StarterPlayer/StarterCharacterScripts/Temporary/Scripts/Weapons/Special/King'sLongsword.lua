local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)
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
local CombatGui = PlayerGui:WaitForChild("CombatGui")
local Background: Frame = CombatGui:WaitForChild("Background")

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
			mass += part:GetMass()
		end
	end
	return mass
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

local KingsLongsword: {
	[Enum.KeyCode]: (action: string, inputstate: string, inputobject: string) -> nil,
} = {
	[Enum.KeyCode.Z] = {
		callback = function(action, inputstate, inputobject)
			if inputstate == Enum.UserInputState.Begin then
				if CheckCooldown("FlashStrike") then
					return
				end

				if Humanoid.Health <= 0 then
					return
				end

				-- # HOLD ATTACK
				local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
					:WaitForChild("FlashStrike Hold")
				local AnimationTrack: AnimationTrack = Animator:LoadAnimation(Animation)

				AnimationTrack:Play(0.15)

				RunService:BindToRenderStep("Lockmouse", Enum.RenderPriority.Camera.Value, Lockmouse)

				RootPart.Anchored = true

				task.spawn(function()
					while true do
						if AnimationTrack.IsPlaying then
							HoldingTime += 0.1
						else
							break
						end
						task.wait(0.1)
					end
				end)

				PlayingAnimation = AnimationTrack
				AnimationTrack:GetMarkerReachedSignal("HoldEnd"):Connect(function()
					AnimationTrack:AdjustSpeed(0)
				end)
			elseif inputstate == Enum.UserInputState.End then
				if CheckCooldown("FlashStrike") then
					return
				end

				if Humanoid.Health <= 0 then
					return
				end

				-- # RELEASE ATTACK
				if PlayingAnimation then
					PlayingAnimation:Stop(0)
				end

				RootPart.Anchored = false

				if HoldingTime > 0.45 then
					SetCooldown("FlashStrike", 1)
					task.spawn(function()
						WeaponService:WeaponInput("FlashStrike", Enum.UserInputState.End, {
							Position = RootPart.CFrame,
						})
					end)

					local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
						:WaitForChild("FlashStrike Release")
					local AnimationTrack: AnimationTrack = Animator:LoadAnimation(Animation)
					AnimationTrack:Play(0)
					AnimationTrack:GetMarkerReachedSignal("attackend"):Connect(function()
						AnimationTrack:AdjustSpeed(0)
					end)

					local V = (Camera.CFrame.LookVector * 60) * GetModelMass(Character)
					RootPart.AssemblyLinearVelocity = V

					VFX:ApplyParticle(Character, "Smoke")
					VFX:ApplyParticle(Character, "Stripes")

					task.delay(0.5, function()
						AnimationTrack:Stop(0.15)
					end)
				end

				RunService:UnbindFromRenderStep("Lockmouse")
				HoldingTime = 0
			end
		end,
		name = "FlashStrike",
	},
	[Enum.KeyCode.X] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if CheckCooldown("LightningWave") then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			SetCooldown("LightningWave", 1)
			RootPart.Anchored = true

			local Animation =
				ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Sword"):WaitForChild("Hit"):WaitForChild("4")

			if PlayingAnimation then
				PlayingAnimation:Stop()
			end

			PlayingAnimation = Animator:LoadAnimation(Animation)
			PlayingAnimation:AdjustSpeed(0.25)
			PlayingAnimation:Play()

			task.spawn(function()
				WeaponService:WeaponInput("LightningWave", Enum.UserInputState.End, {
					Position = RootPart.CFrame,
				})
			end)

			task.wait(1.5)
			RootPart.Anchored = false
		end,
		name = "LightningWave",
	},
	[Enum.KeyCode.V] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			SetCooldown("Lightning", 1)
			WeaponService:WeaponInput("Lightning", Enum.UserInputState.End, {
				Position = RootPart.CFrame,
			})

			local Animation =
				ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Sword"):WaitForChild("Hit"):WaitForChild("4")

			if PlayingAnimation then
				PlayingAnimation:Stop()
			end

			PlayingAnimation = Animator:LoadAnimation(Animation)
			PlayingAnimation:AdjustSpeed(0.25)
			PlayingAnimation:Play(0.15)

			RootPart.Anchored = true
			task.wait(0.9)
			RootPart.Anchored = false
		end,

		name = "Lightning",
	},
}

function KingsLongsword.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return KingsLongsword
