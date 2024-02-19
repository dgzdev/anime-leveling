local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CameraParts = Workspace:WaitForChild("CameraParts")

local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

repeat
	task.wait(1)
until game:IsLoaded()

while true do
	for _, Part in ipairs(CameraParts:GetChildren()) do
		local cam = Workspace.CurrentCamera
		local anim = TweenService:Create(
			cam,
			TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0.25),
			{
				CFrame = Part.CFrame,
			}
		)
		anim:Play()
		anim.Completed:Wait()
		cam.CFrame = Part.CFrame
		task.wait(2)
	end
	task.wait(3)
end
