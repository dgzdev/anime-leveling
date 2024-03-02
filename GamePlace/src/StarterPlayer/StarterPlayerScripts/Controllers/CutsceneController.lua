local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local PlayerEnterService

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
	local Connections = {}

	task.spawn(function()
		local Animation = Animations:WaitForChild(animation)

		local Fov = Animation:WaitForChild("FOV")
		local Frames = Animation:WaitForChild("Frames")
		local Head = Character:WaitForChild("Head")
		local NotChange = {
			"Left Leg",
			"Right Leg",
			"Left Arm",
			"Right Arm",
			"Torso",
		}

		for i = 1, #Frames:GetChildren(), 1 do
			task.wait()
			local Frame = Frames:FindFirstChild(tostring(i))
			local FOVFrame = Fov:FindFirstChild(tostring(i))

			if not Frame then
				continue
			end
			if not Frame then
				continue
			end

			if i == 139 then
				for _, basepart: BasePart in ipairs(Character:GetDescendants()) do
					if basepart:IsA("BasePart") then
						if table.find(NotChange, basepart.Name) then
							continue
						end

						basepart.LocalTransparencyModifier = 1
						Connections[#Connections + 1] = basepart
							:GetPropertyChangedSignal("LocalTransparencyModifier")
							:Connect(function()
								basepart.LocalTransparencyModifier = 1
							end)
					end
				end

				Workspace.CurrentCamera.CameraSubject = Head
			end

			if i == 460 then
				for _, c in ipairs(Connections) do
					c:Disconnect()
				end

				print("volto")
				for _, basepart: BasePart in ipairs(Character:GetDescendants()) do
					if basepart:IsA("BasePart") then
						basepart.LocalTransparencyModifier = basepart.Transparency
						Connections[#Connections + 1] = basepart
							:GetPropertyChangedSignal("LocalTransparencyModifier")
							:Connect(function()
								basepart.LocalTransparencyModifier = basepart.Transparency
							end)
					end
				end

				Workspace.CurrentCamera.CameraSubject = Character
			end

			if i >= 139 and i <= 460 then
				Camera.CFrame = Head.CFrame
				continue
			end

			if i == 1 then
				Camera.CFrame = Frame.Value
				Camera.FieldOfView = FOVFrame.Value
				continue
			end

			local CF = Frame.Value
			local FOV = FOVFrame.Value

			Camera.CFrame = Camera.CFrame:Lerp(CF, 0.1)

			TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
				FieldOfView = FOV,
			}):Play()
		end

		Root.CFrame = Torso.CFrame
		AnimationTrack:Stop()
		task.wait()
		CameraEvent:Fire("Enable")
		task.wait()
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		ReplicatedStorage:SetAttribute("FirstTimeAnimationEnd", true)
		PlayerEnterService:CutsceneEnd(Player)
		Root.Anchored = false
		local PlayerHud = PlayerGui:WaitForChild("PlayerHud")
		PlayerHud.Enabled = true

		local cutscene = PlayerGui:WaitForChild("Cutscene")
		cutscene.Enabled = false

		for _, c in ipairs(Connections) do
			c:Disconnect()
		end
	end)
end

local CutsceneController = Knit.CreateController({
	Name = "CutsceneController",
})

function CutsceneController.Init()
	Root.Anchored = true

	PlayerEnterService:CutsceneStart(Player)

	local cutscene = PlayerGui:WaitForChild("Cutscene")
	cutscene.Enabled = true

	local PlayerHud = PlayerGui:WaitForChild("PlayerHud")
	PlayerHud.Enabled = false

	local loadingGui = PlayerGui:FindFirstChild("loadingScreen", true)
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
		if keyframeName == "end" then
			AnimationTrack:AdjustSpeed(0)
		end
	end)

	AnimationTrack:Play(0)
	task.wait()
	AnimateCamera("Portal Leave")
end

function CutsceneController:KnitStart()
	PlayerEnterService = Knit.GetService("PlayerEnterService")

	task.spawn(function()
		self:Init()
	end)
end

return CutsceneController
