local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CameraModule = Knit.CreateController({
	Name = "CameraController",
})

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character.PrimaryPart
local Subject: BasePart = workspace.CurrentCamera:WaitForChild("CameraSubject")

local Camera = workspace.CurrentCamera

local cameraAngleX = 0
local cameraAngleY = 0
local cameraOffset = Vector3.new(2, 0, 9.5)

local cameraOffsetMin = 3
local cameraOffsetMax = 25

function CameraModule.GetLockCFrame()
	--CFrame.new(Root.Position, Root.Position + Vector3.new(cammer.CFrame.LookVector.X,0,cammer.CFrame.LookVector.Z))
	return CFrame.new(
		Subject.Position,
		Subject.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
	)
end
function CameraModule.GetCameraCFrame()
	return Subject.CFrame * CFrame.new(0, 1.5, 3)
end

function CameraModule.SetCameraLock(deltaTime: number)
	if not Character:IsDescendantOf(workspace) then
		return
	end

	if not Character.PrimaryPart then
		return
	end

	Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

	local c = Workspace.CurrentCamera.CFrame
	local startCFrame = CFrame.new(Subject.CFrame.Position)
		* CFrame.Angles(0, math.rad(cameraAngleX), 0)
		* CFrame.Angles(math.rad(cameraAngleY), 0, 0)
	local cameraCFrame = startCFrame:PointToWorldSpace(cameraOffset)
	local cameraFocus = startCFrame:PointToWorldSpace(Vector3.new(cameraOffset.X, cameraCFrame.Y, -100000))

	local finalCF = CFrame.lookAt(cameraCFrame, cameraFocus)

	local filter = RaycastParams.new()
	filter.RespectCanCollide = true
	filter.CollisionGroup = "Camera"

	local direction = CFrame.new(RootPart.CFrame.Position, finalCF.Position).LookVector
	local distance = (RootPart.Position - finalCF.Position).Magnitude
	local point = workspace:Raycast(RootPart.CFrame.Position, direction * distance, filter)
	if point then
		finalCF = CFrame.lookAt(point.Position, cameraFocus)
	end

	Workspace.CurrentCamera.CFrame = c:Lerp(finalCF, 0.5)

	local LookingCFrame = CFrame.lookAt(RootPart.Position, Camera.CFrame:PointToWorldSpace(Vector3.new(0, 0, -100000)))

	local state = Humanoid:GetState()
	local anchored = Humanoid.RootPart.Anchored == true
	local hasAlignPosition = Humanoid.RootPart:FindFirstChildWhichIsA("AlignPosition") ~= nil

	if (state ~= Enum.HumanoidStateType.StrafingNoPhysics) and (anchored == false) and (hasAlignPosition == false) then
		RootPart.CFrame = CFrame.fromMatrix(RootPart.Position, LookingCFrame.XVector, RootPart.CFrame.YVector)
	end
end

local isLocked = false

Humanoid.Died:Connect(function()
	CameraModule:DisableCamera()

	Character = Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character.PrimaryPart

	CameraModule.CreateContext()
end)

function CameraModule.CreateContext()
	ContextActionService:BindAction("MouseMovement", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Change then
			cameraAngleX -= inputObject.Delta.X * 0.4
			cameraAngleY = math.clamp(cameraAngleY - inputObject.Delta.Y * 0.4, -75, 75)
		else
			return Enum.ContextActionResult.Pass
		end
	end, false, Enum.UserInputType.MouseMovement)

	ContextActionService:BindAction("CameraOffset", function(actionName, inputState, inputObject)
		if not isLocked then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Change then
			cameraOffset = Vector3.new(
				cameraOffset.X,
				cameraOffset.Y,
				math.clamp(cameraOffset.Z - inputObject.Position.Z, cameraOffsetMin, cameraOffsetMax)
			)
		end
	end, false, Enum.UserInputType.MouseWheel)

	ContextActionService:BindAction("CameraLock", function(actionName, inputState, inputObject)
		if Humanoid.Health == 0 then
			return Enum.ContextActionResult.Pass
		end

		if inputState == Enum.UserInputState.Begin then
			if isLocked then
				isLocked = false
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				Humanoid.AutoRotate = true
				RunService:UnbindFromRenderStep("CameraLock")
			else
				isLocked = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				Humanoid.AutoRotate = false
				RunService:BindToRenderStep("CameraLock", Enum.RenderPriority.Camera.Value, function(dt)
					CameraModule.SetCameraLock(dt)
				end)
			end
		else
			return Enum.ContextActionResult.Pass
		end
	end, false, Enum.KeyCode.LeftShift)
end

function CameraModule:DisableCamera()
	ContextActionService:UnbindAction("MouseMovement")
	ContextActionService:UnbindAction("CameraLock")

	if isLocked then
		isLocked = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		Humanoid.AutoRotate = true
		RunService:UnbindFromRenderStep("CameraLock")
	end

	Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
end
function CameraModule:EnableCamera()
	CameraModule.CreateContext()

	Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

return CameraModule
