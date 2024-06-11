if not game:IsLoaded() then
    game.Loaded:Wait()
end

local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character:WaitForChild("Head")

local CameraSubject

if workspace.CurrentCamera:FindFirstChild("CameraSubject") then
    CameraSubject = workspace.CurrentCamera:FindFirstChild("CameraSubject")
else
    CameraSubject = Instance.new("Part")
end

CameraSubject.Name = "CameraSubject"

CameraSubject.Anchored = true
CameraSubject.CanCollide = false
CameraSubject.Size = Vector3.new(0.1, 0.1, 0.1)
CameraSubject.Transparency = 1

CameraSubject.Parent = workspace.CurrentCamera
CameraSubject.CFrame = Head.CFrame

workspace.CurrentCamera.CameraSubject = CameraSubject

RunService:BindToRenderStep("CameraSubject", Enum.RenderPriority.Camera.Value, function(delta)
    CameraSubject.CFrame = CameraSubject.CFrame:Lerp(Head.CFrame, 0.5)
end)


Player.CharacterAdded:Connect(function(character)
    Character = character
    Head = Character:WaitForChild("Head")
    CameraSubject.CFrame = Head.CFrame
end)