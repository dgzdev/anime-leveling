local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local PlayerService
local CameraController

local HumanoidHandler = Knit.CreateController({
	Name = "HumanoidHandler",
})

-- local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- local DyingGui = PlayerGui:WaitForChild("DyingGui")
-- local Background = DyingGui:WaitForChild("Background")
-- local Respawn = Background:WaitForChild("Respawn")

-- local HealthScreen: ScreenGui = PlayerGui:WaitForChild("Health")
-- local HealthEffect: ImageLabel = HealthScreen:WaitForChild("HealthEffect")

-- local Player = Players.LocalPlayer
-- local Character
-- local Humanoid
-- local Animator: Animator

-- local VFX = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("VFX"))

-- function HumanoidHandler:OnLand()
-- 	VFX:ApplyParticle(Character, "Fell", nil, Vector3.new(0, -2, 0), true)
-- 	local Animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Landed")
-- 	local AnimationTrack = Animator:LoadAnimation(Animation)
-- 	AnimationTrack:Play(0.15)
-- end

-- function HumanoidHandler:OnFallingDown()
-- 	VFX:ApplyParticle(Character, "Falling", nil, nil, true)
-- end

-- function HumanoidHandler:BindHumanoid(Humanoid: Humanoid)
-- 	--[[
-- 	Respawn.Activated:Connect(function(inputObject, clickCount)
-- 		PlayerService:Respawn()
-- 	end)
-- 	]]

-- 	Humanoid.HealthChanged:Connect(function(health)
-- 		local scale = math.clamp(health / Humanoid.MaxHealth, 0, 1)

-- 		if scale <= 0.3 then
-- 			HealthScreen.Enabled = true

-- 			TweenService:Create(
-- 				HealthEffect,
-- 				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0),
-- 				{
-- 					ImageTransparency = scale + 0.3,
-- 				}
-- 			):Play()
-- 		else
-- 			HealthScreen.Enabled = false
-- 		end
-- 	end)

-- 	Humanoid.StateChanged:Connect(function(old, new)
-- 		if new == Enum.HumanoidStateType.Landed then
-- 			self:OnLand()
-- 		end
-- 		if new == Enum.HumanoidStateType.Freefall then
-- 			self:OnFallingDown()
-- 		end
-- 	end)
-- end

-- function HumanoidHandler:KnitInit()
-- 	PlayerService = Knit.GetService("PlayerService")
-- 	CameraController = Knit.GetController("CameraController")
-- end

-- function HumanoidHandler:KnitStart()
-- 	coroutine.wrap(function()
-- 		Character = Player.Character or Player.CharacterAdded:Wait()
-- 		Humanoid = Character:WaitForChild("Humanoid")
-- 		Animator = Humanoid:WaitForChild("Animator")

-- 		Player.CharacterAdded:Connect(function(character)
-- 			Character = character
-- 			Humanoid = character:WaitForChild("Humanoid")
-- 			Animator = Humanoid:WaitForChild("Animator")
-- 			self:BindHumanoid(Humanoid)
-- 		end)

-- 		self:BindHumanoid(Humanoid)
-- 	end)()
-- end

return HumanoidHandler
