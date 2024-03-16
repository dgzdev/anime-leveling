local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

if not ReplicatedStorage:GetAttribute("FirstTimeAnimationEnd") then
	local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA") :: BindableEvent
	CameraEvent.Event:Wait()
end

if character:FindFirstChild("HeadSubject") then
	character:FindFirstChild("HeadSubject"):Destroy()
end

local HeadSubject = Instance.new("Part")
HeadSubject.Size = Vector3.new(0.1, 0.1, 0.1)
HeadSubject.Anchored = true
HeadSubject.CanCollide = false
HeadSubject.Transparency = 1
HeadSubject.Massless = true
HeadSubject.CanTouch = false
HeadSubject.CanQuery = false
HeadSubject.CollisionGroup = "Players"
HeadSubject.Name = "HeadSubject"
HeadSubject.Parent = character

local Head = character:WaitForChild("Head") :: BasePart
HeadSubject.CFrame = Head.CFrame * CFrame.new(0, -0.2, 0)

RunService:BindToRenderStep("HeadSubject", Enum.RenderPriority.Last.Value, function()
	local currentCFrame = HeadSubject.CFrame
	local targetCFrame = Head.CFrame * CFrame.new(0, -0.2, 0)

	HeadSubject.CFrame = currentCFrame:Lerp(targetCFrame, 0.25)
end)
