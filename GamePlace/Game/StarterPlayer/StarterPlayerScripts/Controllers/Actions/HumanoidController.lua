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

local Player = Players.LocalPlayer
local Character
local Humanoid
local Animator: Animator

local VFX = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("VFX"))

function HumanoidHandler:OnLand()
	VFX:ApplyParticle(Character, "Fell", nil, Vector3.new(0, -2, 0), true)
	local Animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Landed")
	local AnimationTrack = Animator:LoadAnimation(Animation)
	AnimationTrack:Play(0.15)
end

function HumanoidHandler:OnFallingDown()
	VFX:ApplyParticle(Character, "Falling", nil, nil, true)
end

function HumanoidHandler:BindHumanoid(Humanoid: Humanoid)
	Humanoid.Died:Connect(function()
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local Died = PlayerGui:WaitForChild("Died")
		local diedBackground = Died:WaitForChild("Background") :: Frame
		local diedTitle = diedBackground:WaitForChild("Title") :: TextLabel
		local diedRespawn = diedBackground:WaitForChild("Respawn") :: TextButton
		local diedRespawnStroke = diedRespawn:WaitForChild("UIStroke") :: UIStroke

		Died.Enabled = true

		diedRespawn.Activated:Once(function()
			PlayerService:Respawn(Player)
			task.wait()
			CameraEvent:Fire("Lock")
		end)

		diedBackground.BackgroundTransparency = 1
		diedTitle.TextTransparency = 1
		diedRespawn.TextTransparency = 1
		diedRespawnStroke.Transparency = 1

		TweenService:Create(diedBackground, TweenInfo.new(1.2), {
			BackgroundTransparency = 0.3,
		}):Play()
		TweenService
			:Create(diedTitle, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.6), {
				TextTransparency = 0,
			})
			:Play()
		TweenService
			:Create(diedRespawn, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3), {
				TextTransparency = 0,
			})
			:Play()
		TweenService
			:Create(
				diedRespawnStroke,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3),
				{
					Transparency = 0,
				}
			)
			:Play()
	end)
	Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			self:OnLand()
		end
		if new == Enum.HumanoidStateType.Freefall then
			self:OnFallingDown()
		end
	end)
end

function HumanoidHandler:KnitInit()
	PlayerService = Knit.GetService("PlayerService")
	CameraController = Knit.GetController("CameraController")
end

function HumanoidHandler:KnitStart()
	coroutine.wrap(function()
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
		Animator = Humanoid:WaitForChild("Animator")

		local function UnlockMouse()
			CameraController:ToggleMouseLock(false)
		end

		Player.CharacterAdded:Connect(function(character)
			Character = character
			Humanoid = character:WaitForChild("Humanoid")
			Animator = Humanoid:WaitForChild("Animator")
			self:BindHumanoid(Humanoid)

			Humanoid.Died:Once(UnlockMouse)
		end)

		Humanoid.Died:Once(UnlockMouse)

		self:BindHumanoid(Humanoid)
	end)()
end

return HumanoidHandler
