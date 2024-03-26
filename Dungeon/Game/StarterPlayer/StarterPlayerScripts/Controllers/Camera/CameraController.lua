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

function CameraModule.LockCharacter(name: string | "MOUSE_LOCKIN", lock: boolean?)
	local Lock: AlignOrientation = RootPart:WaitForChild("BodyLock")

	local function Enable()
		name = name or "MOUSE_LOCKIN"
		Lock.Enabled = true
		RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value, function(delta: number)
			Lock.CFrame = CameraModule.GetLockCFrame()
		end)
	end

	local function Disable()
		Lock.Enabled = false
		RunService:UnbindFromRenderStep(name)
	end

	if lock then
		Lock.Enabled = lock
		if lock == true then
			Enable()
		elseif lock == false then
			Disable()
		end
	else
		if Lock.Enabled == false then
			Enable()
		elseif Lock.Enabled == true then
			Disable()
		end
	end

	return name
end

function CameraModule:ToggleMouseLock(boolean: boolean?)
	local Lock: AlignOrientation = RootPart:WaitForChild("BodyLock")

	OTS:SetMouseStep(boolean or not OTS.IsMouseSteppedIn)
end

function CameraModule:KnitInit()
	task.spawn(function()
		Player.CharacterAdded:Connect(function()
			Character = Player.Character
			Humanoid = Character:WaitForChild("Humanoid")
			RootPart = Character.PrimaryPart
			Torso = Character:WaitForChild("Head")
		end)

		Camera.CameraSubject = Torso

		if playerGui:FindFirstChild("loadingScreen") then
			playerGui:FindFirstChild("loadingScreen").Destroying:Wait()
		end

		local limits = { 8, 32 }

		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local UP = input.Position.Z < 0
				if UP then
					for i, v in OTS.CameraSettings do
						v.Offset = Vector3.new(v.Offset.X, v.Offset.Y, math.clamp(v.Offset.Z + 1, limits[1], limits[2]))
					end
				else
					for i, v in OTS.CameraSettings do
						v.Offset = Vector3.new(v.Offset.X, v.Offset.Y, math.clamp(v.Offset.Z - 1, limits[1], limits[2]))
					end
				end
			end
		end)

		ContextActionService:BindActionAtPriority(
			"LockMouse",
			function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
				if inputState == Enum.UserInputState.Begin then
					CameraModule.LockCharacter("MOUSE_LOCKIN")
				end
			end,
			false,
			100,
			Enum.KeyCode.LeftAlt
		)

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
		CameraModule:ToggleMouseLock(true)
	elseif action == "Unlock" then
		--[[
		if CurrentCamera == "OTS" then
			CameraModule.OTS:SetMouseStep(false)
		elseif CurrentCamera == "LOCKON" then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end
		]]
		CameraModule:ToggleMouseLock(false)
	end

	if action == "FOV" then
		local FOV = ...
		--CameraModule.OTS.CameraSettings.DefaultShoulder.FieldOfView = FOV
	end
end)

return CameraModule
