local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CameraModule = Knit.CreateController({
	Name = "CameraController",
})

local OTS = require(game.ReplicatedStorage.Modules.OTS)
local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local Player = game.Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character.PrimaryPart
local Torso = Character:WaitForChild("Head")

local Camera = workspace.CurrentCamera

function CameraModule.GetLockCFrame()
	--CFrame.new(Root.Position, Root.Position + Vector3.new(cammer.CFrame.LookVector.X,0,cammer.CFrame.LookVector.Z))
	return CFrame.new(
		RootPart.Position,
		RootPart.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
	)
end

function CameraModule.LockCharacter(name: string | "MOUSE_LOCKIN")
	local Lock: AlignOrientation = RootPart:WaitForChild("BodyLock")
	name = name or "MOUSE_LOCKIN"
	RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value, function(delta: number)
		Lock.CFrame = CameraModule.GetLockCFrame()
	end)
	return name
end

function CameraModule:ToggleMouseLock()
	local Lock: AlignOrientation = RootPart:WaitForChild("BodyLock")

	if OTS.IsMouseSteppedIn then
		-- Unlock the mouse
		OTS:SetMouseStep(false)

		RunService:UnbindFromRenderStep("MOUSE_LOCKIN")
		Lock.Enabled = false
		Humanoid.AutoRotate = false
		Camera.CameraSubject = Torso
	elseif OTS.IsMouseSteppedIn == false then
		-- Lock the mouse

		OTS:SetMouseStep(true)

		CameraModule.LockCharacter()
		Lock.Enabled = true
		Humanoid.AutoRotate = false
	end
end

function CameraModule:KnitInit()
	task.spawn(function()
		Camera.CameraSubject = Torso

		if playerGui:FindFirstChild("loadingScreen") then
			playerGui:FindFirstChild("loadingScreen").Destroying:Wait()
		end

		if not ReplicatedStorage:GetAttribute("FirstTimeAnimationEnd") then
			ReplicatedStorage:GetAttributeChangedSignal("FirstTimeAnimationEnd"):Wait()
		end

		OTS:Enable()
	end)
end

CameraEvent.Event:Connect(function(action: string, ...)
	if action == "Enable" then
		--[[
		if CurrentCamera == "LOCKON" then
			CameraModule.ToggleCameras("toggle", Enum.UserInputState.Begin, Enum.KeyCode.CapsLock)
		end
		]]

		CameraModule:ToggleMouseLock()
	elseif action == "Disable" then
		--[[
		if CurrentCamera == "LOCKON" then
			CameraModule.ToggleCameras("toggle", Enum.UserInputState.Begin, Enum.KeyCode.CapsLock)
		end
		CameraModule:DisableCamera()
		]]

		CameraModule:ToggleMouseLock()
	end

	if action == "Lock" then
		--[[

		if CurrentCamera == "OTS" then
			CameraModule.OTS:SetMouseStep(true)
		elseif CurrentCamera == "LOCKON" then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end

		]]
		CameraModule:ToggleMouseLock()
	elseif action == "Unlock" then
		--[[
		if CurrentCamera == "OTS" then
			CameraModule.OTS:SetMouseStep(false)
		elseif CurrentCamera == "LOCKON" then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end
		]]
		CameraModule:ToggleMouseLock()
	end

	if action == "FOV" then
		local FOV = ...
		--CameraModule.OTS.CameraSettings.DefaultShoulder.FieldOfView = FOV
	end
end)

return CameraModule
