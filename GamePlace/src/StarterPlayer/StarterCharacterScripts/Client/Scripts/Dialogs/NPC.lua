local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local NPC = {}

local Player = Players.LocalPlayer

local Camera = require(script.Parent:WaitForChild("Camera"))
local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")

function NPC.OnTrigger(properties: { Title: string, Dialogs: { string }, NPC: Model })
	local Name = properties.Title
	local Menus = Player:WaitForChild("PlayerGui"):WaitForChild("Menus")
	local Dialogs = Menus:WaitForChild("Dialog")

	Dialogs.Enabled = true
	local Background = Dialogs:WaitForChild("Background") :: TextButton
	local Text = Background:WaitForChild("Dialog")
	local Title = Text:WaitForChild("Title")

	Background.Position = UDim2.fromScale(0, 1)
	Background.BackgroundTransparency = 1

	TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Position = UDim2.fromScale(0, 0),
	}):Play()
	TweenService:Create(Background, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		BackgroundTransparency = 0,
	}):Play()

	for _, object in ipairs(Background:GetDescendants()) do
		if object:IsA("TextLabel") then
			object.TextTransparency = 1
			TweenService:Create(object, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
				TextTransparency = 0,
			}):Play()
		elseif object:IsA("TextButton") then
			object.TextTransparency = 1
			TweenService:Create(object, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
				TextTransparency = 0,
			}):Play()
		end
	end
	Camera:EnableMouse()

	for _, Dialog in ipairs(properties.Dialogs) do
		Title.Text = Name
		Text.Text = Dialog

		Background.Activated:Wait()
	end
	Dialogs.Enabled = false
	CameraEvent:Fire("Lock")
end

return NPC
