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

local KingsLongsword = {
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

			if inputstate == Enum.UserInputState.Begin then
				if CheckCooldown("FlashStrike") then
					return
				end

				if Humanoid.Health <= 0 then
					return
				end

				if Character:GetAttribute("Stun") then
					return
				end

				-- # HOLD ATTACK
				local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
					:WaitForChild("FlashStrike Hold")
				PlayingAnimation = Animator:LoadAnimation(Animation)

				PlayingAnimation:Play(0.15)

				RunService:BindToRenderStep("Lockmouse", Enum.RenderPriority.Camera.Value, Lockmouse)

				RootPart.Anchored = true

				task.spawn(function()
					local anim = PlayingAnimation.Name
					while true do
						if anim ~= PlayingAnimation.Name then
							break
						end

						if PlayingAnimation.IsPlaying then
							HoldingTime += 0.1
						else
							break
						end
						task.wait(0.1)
					end
				end)

				PlayingAnimation = PlayingAnimation
				PlayingAnimation:GetMarkerReachedSignal("HoldEnd"):Connect(function()
					PlayingAnimation:AdjustSpeed(0)
				end)
			elseif inputstate == Enum.UserInputState.End then
				-- # RELEASE ATTACK
				if PlayingAnimation then
					PlayingAnimation:Stop(0)
				end
				RunService:UnbindFromRenderStep("Lockmouse")

				if CheckCooldown("FlashStrike") then
					return
				end

				if Humanoid.Health <= 0 then
					return
				end

				if Character:GetAttribute("Stun") then
					return
				end

				RootPart.Anchored = false

				if HoldingTime > 0.45 then
					HoldingTime = 0
					SetCooldown("FlashStrike", 1)

					SFX:Create(RootPart, "Rebellion slash", 0, 60, false)

					task.spawn(function()
						WeaponService:WeaponInput("FlashStrike", Enum.UserInputState.End, {
							Position = RootPart.CFrame,
							Camera = Camera.CFrame,
						})
					end)

					local Animation: Animation = ReplicatedStorage:WaitForChild("Animations")
						:WaitForChild("FlashStrike Release")
					PlayingAnimation = Animator:LoadAnimation(Animation)
					PlayingAnimation:Play(0)
					PlayingAnimation:GetMarkerReachedSignal("attackend"):Connect(function()
						PlayingAnimation:AdjustSpeed(0)
					end)

					local V = (Camera.CFrame.LookVector * 200) * GetModelMass(Character)
					RootPart.AssemblyLinearVelocity = V * Vector3.new(1, 0.4, 1)

					VFX:ApplyParticle(Character, "Smoke")
					VFX:ApplyParticle(Character, "Stripes")

					task.delay(0.5, function()
						PlayingAnimation:Stop(0.3)
					end)
				else
					HoldingTime = 0
				end
			end
		end,
		name = "FlashStrike",
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

			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if CheckCooldown("Eletric Wave") then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			SetCooldown("Eletric Wave", 1)
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
				WeaponService:WeaponInput("Eletric Wave", Enum.UserInputState.End, {
					Position = RootPart.CFrame,
				})
			end)

			task.wait(1.5)
			RootPart.Anchored = false
		end,
		name = "Eletric Wave",
	},
	[Enum.KeyCode.V] = {
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

			if CheckCooldown("Lightning") then
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
	ShakerController = Knit.GetController("ShakerController")
end

return KingsLongsword
