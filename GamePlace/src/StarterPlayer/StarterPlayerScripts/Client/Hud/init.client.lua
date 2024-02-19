local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	Level.Text = "0"
	PlayerName.Text = Player.Name
	PlayerImage.Image =
		Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end

UpdateHud()

local PlayerHud = ReplicatedStorage.Events:WaitForChild("PlayerHud") :: RemoteEvent
PlayerHud.OnClientEvent:Connect(function(name: string, value: any)
	UpdateHud(name, value)
end)
