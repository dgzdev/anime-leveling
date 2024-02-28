local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Join = {}

local Camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")
local Torso = Character:WaitForChild("Torso")
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local AnimationTrack: AnimationTrack

local Animations = ReplicatedStorage:WaitForChild("CameraAnimations")

local function AnimateCamera(animation: string)
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = Workspace:WaitForChild("Portal")
	task.spawn(function()
		local Animation = Animations:WaitForChild(animation)

		local Frames = Animation:WaitForChild("Frames")
		for i = 1, #Frames:GetChildren(), 1 do
			local Frame = Frames:FindFirstChild(tostring(i))
			if not Frame then
				break
			end
			local CFrame = Frame.Value

			Camera.CFrame = CFrame
			task.wait()
		end

		Root.CFrame = Torso.CFrame
		AnimationTrack:Stop()
		task.wait()
		CameraEvent:Fire("Enable")
		task.wait()
		Root.Anchored = false
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

function Join:Init()
	repeat
		Root.Anchored = true
		task.wait()
	until Root.Anchored == true

	Humanoid.AutoRotate = false

	local loadingGui = Player:FindFirstChild("loadingScreen", true)
	if loadingGui then
		loadingGui.Destroying:Wait()
	end

	local Animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Portal")
	AnimationTrack = Animator:LoadAnimation(Animation)

	AnimationTrack.Looped = false

	AnimationTrack.KeyframeReached:Connect(function(keyframeName)
		if keyframeName == "hit" then
			SoundService:WaitForChild("Join"):WaitForChild("hit1"):Play()
		end
		if keyframeName == "look" then
			AnimationTrack:AdjustSpeed(0)
		end
	end)

	AnimationTrack:Play(0)
	task.wait()
	AnimateCamera("Portal Leave")

	ReplicatedStorage:SetAttribute("FirstTimeAnimationEnd", true)
end

return Join
