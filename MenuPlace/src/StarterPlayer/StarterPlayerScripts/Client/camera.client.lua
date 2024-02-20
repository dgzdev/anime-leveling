local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CameraParts = Workspace:WaitForChild("CameraParts")

local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

local IsLoaded = Players:GetAttribute("Loaded")
if not IsLoaded then
	Players:GetAttributeChangedSignal("Loaded"):Wait()
end

local firstTime = true
local Styles = {
	Enum.EasingStyle.Linear,
	Enum.EasingStyle.Sine,
	Enum.EasingStyle.Quad,
	Enum.EasingStyle.Quart,
	Enum.EasingStyle.Quint,
	Enum.EasingStyle.Exponential,
}

task.spawn(function()
	while true do
		for _, music: Sound in ipairs(SoundService:WaitForChild("Music"):GetChildren()) do
			music.Volume = 0
			TweenService:Create(music, TweenInfo.new(2), { Volume = 0.5 }):Play()
			music:Play()
			music.Ended:Wait()
		end
	end
end)

while true do
	for _, Part in ipairs(CameraParts:GetChildren()) do
		if firstTime == true then
			Camera.CFrame = Part.CFrame
			firstTime = false
			continue
		end

		local cam = Workspace.CurrentCamera
		local anim = TweenService:Create(
			cam,
			TweenInfo.new(
				math.random(3, 12),
				Styles[math.random(1, #Styles)],
				Enum.EasingDirection.InOut,
				0,
				false,
				0.25
			),
			{
				CFrame = Part.CFrame,
			}
		)
		anim:Play()
		anim.Completed:Wait()
		cam.CFrame = Part.CFrame
		task.wait(math.random(2, 4))
	end
	task.wait(math.random(3, 6))
end
