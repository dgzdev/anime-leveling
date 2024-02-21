local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local HeadSubject = character:WaitForChild("HeadSubject") :: BasePart
local Head = character:WaitForChild("Head") :: BasePart

RunService:BindToRenderStep("HeadSubject", Enum.RenderPriority.Last.Value, function()
	local currentCFrame = HeadSubject.CFrame
	local targetCFrame = Head.CFrame * CFrame.new(0, -0.2, 0)

	HeadSubject.CFrame = currentCFrame:Lerp(targetCFrame, 0.25)
end)
