local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UI = PlayerGui:WaitForChild("UI")
local Main = UI:WaitForChild("Main") :: ScreenGui
local Background = Main:WaitForChild("Background") :: Frame
local Slider = Background:WaitForChild("Slider") :: ImageLabel

local Level = Slider:WaitForChild("Level") :: TextLabel
local PlayerName = Slider:WaitForChild("PlayerName") :: TextLabel

local Moldura = Background:WaitForChild("Moldura") :: ImageLabel
local PlayerImage = Moldura:WaitForChild("PlayerImage") :: ImageLabel

local XP = Background:WaitForChild("XP") :: ImageLabel
local Progress = XP:WaitForChild("Progress") :: Frame

repeat
	task.wait(1)
until game:IsLoaded()

local function UpdateHud(index: string, value: any)
	if index == "Level" then
		Level.Text = tostring(value)
		return
	elseif index == "PlayerName" then
		PlayerName.Text = value
		return
	end

	if index == "Image" then
		PlayerImage.Image =
			Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		return
	end

	if index == "LevelUP" then
		Level.Text = tostring(value)
		TweenService:Create(Progress, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = UDim2.fromScale(0, 1),
		}):Play()

		-- PlaySound
		local Sound = SoundService:WaitForChild("SFX"):WaitForChild("LevelUP")
		SoundService:PlayLocalSound(Sound)

		print("levelup")

		return
	end

	if index == "XP" then
		local progress = value / (tonumber(Level.Text) * 243)
		TweenService:Create(Progress, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = UDim2.fromScale(progress, 1),
		}):Play()
	end

	if index == nil then
		Level.Text = "0"
		PlayerName.Text = Player.Name
		PlayerImage.Image =
			Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		Progress.Size = UDim2.fromScale(0, 1)
	end
end

UpdateHud()

local PlayerHud = ReplicatedStorage.Events:WaitForChild("PlayerHud") :: RemoteEvent
PlayerHud.OnClientEvent:Connect(function(name: string, value: any)
	UpdateHud(name, value)
end)
