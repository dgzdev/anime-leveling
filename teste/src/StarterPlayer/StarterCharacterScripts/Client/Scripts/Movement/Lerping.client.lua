local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")
local InputS = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

local targetMoveVelocity = Vector3.new()
local moveVelocity = Vector3.new()
local moveAcceleration = 8

player.CharacterAdded:Connect(function(_character)
	character = _character
end)

local walkKeyBinds = {
	Forward = { Key = Enum.KeyCode.W, Direction = Enum.NormalId.Front },
	Backward = { Key = Enum.KeyCode.S, Direction = Enum.NormalId.Back },
	Left = { Key = Enum.KeyCode.A, Direction = Enum.NormalId.Left },
	Right = { Key = Enum.KeyCode.D, Direction = Enum.NormalId.Right },
}

if not ReplicatedStorage:GetAttribute("FirstTimeAnimationEnd") then
	local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA") :: BindableEvent
	CameraEvent.Event:Wait()
end

local function getWalkDirectionCameraSpace()
	local walkDir = Vector3.new()

	for keyBindName, keyBind in pairs(walkKeyBinds) do
		if InputS:IsKeyDown(keyBind.Key) then
			walkDir += Vector3.FromNormalId(keyBind.Direction)
		end
	end

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local function getWalkDirectionWorldSpace()
	local walkDir = camera.CFrame:VectorToWorldSpace(getWalkDirectionCameraSpace())
	walkDir *= Vector3.new(1, 0, 1) --Set Y axis to 0

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local function updateMovement(dt)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local moveDir = getWalkDirectionWorldSpace()
		targetMoveVelocity = moveDir
		moveVelocity = moveVelocity:Lerp(targetMoveVelocity, math.clamp(dt * moveAcceleration, 0, 1))
		humanoid:Move(moveVelocity)
	end
end

RunS.RenderStepped:Connect(updateMovement)
