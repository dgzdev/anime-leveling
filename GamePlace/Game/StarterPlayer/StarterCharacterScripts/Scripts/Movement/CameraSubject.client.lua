if not game:IsLoaded() then
	game.Loaded:Wait()
end

local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:WaitForChild("Torso")

local CameraSubject

if workspace.CurrentCamera:FindFirstChild("CameraSubject") then
	CameraSubject = workspace.CurrentCamera:FindFirstChild("CameraSubject")
else
	CameraSubject = Instance.new("Part")
end

local offset = CFrame.new(0, 0.5, 0)

CameraSubject.Name = "CameraSubject"

CameraSubject.Anchored = true
CameraSubject.CanCollide = false
CameraSubject.Size = Vector3.new(0.1, 0.1, 0.1)
CameraSubject.Transparency = 1

CameraSubject.Parent = workspace.CurrentCamera
CameraSubject.CFrame = Torso.CFrame

workspace.CurrentCamera.CameraSubject = CameraSubject

RunService:BindToRenderStep("CameraSubject", Enum.RenderPriority.Camera.Value, function(delta)
	CameraSubject.CFrame = CameraSubject.CFrame:Lerp(Torso.CFrame, 0.5) * CFrame.new(Humanoid.CameraOffset) * offset
end)

Player.CharacterAdded:Connect(function(character)
	Character = character
	Torso = Character:WaitForChild("Torso")
	CameraSubject.CFrame = Torso.CFrame
end)
