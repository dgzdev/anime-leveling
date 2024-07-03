local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local PlayerEnterService
local CameraController
local HumanoidManagerController

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local PlayerGui = Player:WaitForChild("PlayerGui")

local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local AnimationTrack: AnimationTrack

local Animations = ReplicatedStorage:WaitForChild("CameraAnimations")

-----------------------------------------------------------------------------------
-- Variables
-----------------------------------------------------------------------------------
local shouldSkipCutscene = RunService:IsStudio() == true

local function AnimateCamera(animation: string)
	Camera.CameraType = Enum.CameraType.Scriptable
	local Connections = {}

	local cameraCFrame = Camera.CFrame
	local lerp = 0.85

	RunService:BindToRenderStep("AnimateCamera", Enum.RenderPriority.Camera.Value, function(deltaTime: number)
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(cameraCFrame, lerp)
	end)

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

		local Torso = Character:WaitForChild("Torso")

		for i = 1, #Frames:GetChildren(), 1 do
			task.wait(1 / 60)

			local Frame = Frames:FindFirstChild(tostring(i))
			local FOVFrame = Fov:FindFirstChild(tostring(i))

			if not Frame then
				break
			end

			if i == 139 then
				lerp = 0.435
				Connections[#Connections + 1] = Character.DescendantAdded:Connect(function(desc: BasePart)
					if desc:IsA("BasePart") then
						local basepart = desc
						if table.find(NotChange, basepart.Name) then
							return
						end

						basepart.LocalTransparencyModifier = 1
						Connections[#Connections + 1] = basepart
							:GetPropertyChangedSignal("LocalTransparencyModifier")
							:Connect(function()
								basepart.LocalTransparencyModifier = 1
							end)
					end
				end)

				for _, basepart: BasePart in (Character:GetDescendants()) do
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
				for _, c in Connections do
					c:Disconnect()
				end

				for _, basepart: BasePart in (Character:GetDescendants()) do
					if basepart:IsA("BasePart") then
						basepart.LocalTransparencyModifier = 0
						Connections[#Connections + 1] = basepart
							:GetPropertyChangedSignal("LocalTransparencyModifier")
							:Connect(function()
								basepart.LocalTransparencyModifier = 0
							end)
					end
				end

				Workspace.CurrentCamera.CameraSubject = Character
			end

			if i >= 139 and i <= 460 then
				cameraCFrame = Head.CFrame
				continue
			end

			if i == 1 then
				cameraCFrame = Frame.Value
				Camera.FieldOfView = FOVFrame.Value
				continue
			end

			local CF = Frame.Value
			local FOV = FOVFrame.Value

			cameraCFrame = CF

			TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
				FieldOfView = FOV,
			}):Play()
		end

		RunService:UnbindFromRenderStep("AnimateCamera")

		Root.CFrame = Torso.CFrame
		task.wait()
		AnimationTrack:Stop()
		task.wait()
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		ReplicatedStorage:SetAttribute("FirstTimeAnimationEnd", true)
		PlayerEnterService:CutsceneEnd(Player)
		Root.Anchored = false
		local PlayerHud = PlayerGui:WaitForChild("PlayerHud")
		PlayerHud.Enabled = true

		local cutscene = PlayerGui:WaitForChild("Cutscene")
		cutscene.Enabled = false

		for _, c in Connections do
			c:Disconnect()
		end

		Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		Workspace.City.JoinPortal:Destroy()

		CameraController:EnableCamera()

		HumanoidManagerController:RunForAllHumanoidsExcept(function(humanoid: Humanoid)
			local parent = humanoid.Parent

			for _, bp: BasePart in parent:GetDescendants() do
				if bp:IsA("BasePart") then
					bp.LocalTransparencyModifier = 0
				end
			end
		end, Humanoid)
	end)
end

local CutsceneController = Knit.CreateController({
	Name = "CutsceneController",
})

function CutsceneController.Init()
	local CutscenePosition: BasePart = Workspace:WaitForChild("CutscenePosition")

	Root.Anchored = true
	Character:PivotTo(CutscenePosition.CFrame)

	local cutscene = PlayerGui:WaitForChild("Cutscene")
	cutscene.Enabled = true

	local PlayerHud = PlayerGui:WaitForChild("PlayerHud")
	PlayerHud.Enabled = false

	local Animation = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Portal")
	AnimationTrack = Animator:LoadAnimation(Animation)

	AnimationTrack.KeyframeReached:Connect(function(keyframeName)
		if keyframeName == "leave" then
			local teleport = SoundService:WaitForChild("Join"):WaitForChild("teleport")
			teleport:Clone()

			if teleport.Playing then
				return
			end

			teleport.Parent = Workspace.City:WaitForChild("JoinPortal"):WaitForChild("01")
			teleport:Play()

			teleport.Ended:Once(function()
				teleport:Destroy()
			end)
		end

		if keyframeName == "look" then
			local swing = SoundService:WaitForChild("Join"):WaitForChild("Swing")
			if swing.Playing then
				return
			end
			swing:Play()
		end

		if keyframeName == "levantando" then
			local levantando = SoundService:WaitForChild("Join"):WaitForChild("getup")
			if levantando.Playing then
				return
			end
			levantando:Play()
		end

		if keyframeName == "hit" then
			local hit = SoundService:WaitForChild("Join"):WaitForChild("hit1")
			if hit.Playing then
				return
			end
			hit:Play()
		end
		if keyframeName == "end" then
			AnimationTrack:AdjustSpeed(0)
		end
	end)

	HumanoidManagerController:RunForAllHumanoidsExcept(function(humanoid: Humanoid)
		local parent = humanoid.Parent

		for _, bp: BasePart in parent:GetDescendants() do
			if bp:IsA("BasePart") then
				bp.LocalTransparencyModifier = 1
			end
		end
	end, Humanoid)

	if not game:GetAttribute("Loaded") then
		game:GetAttributeChangedSignal("Loaded"):Wait()
	end

	AnimationTrack:Play()
	AnimateCamera("Portal Leave")
end

function CutsceneController:KnitInit()
	PlayerEnterService = Knit.GetService("PlayerEnterService")
	CameraController = Knit.GetController("CameraController")
	HumanoidManagerController = Knit.GetController("HumanoidManagerController")

	Humanoid.Died:Connect(function()
		Character = Player.CharacterAdded:Wait()
		Root = Character:WaitForChild("HumanoidRootPart")
		Humanoid = Character:WaitForChild("Humanoid")
		Animator = Humanoid:WaitForChild("Animator")

		CameraController:EnableCamera()
	end)

	if shouldSkipCutscene then
		ReplicatedStorage:SetAttribute("FirstTimeAnimationEnd", true)
		Root.Anchored = false
		PlayerGui:WaitForChild("PlayerHud").Enabled = true
		CameraController:EnableCamera()
		Workspace.City.JoinPortal:Destroy()
		return
	else
		self.Init()
	end
end

return CutsceneController
