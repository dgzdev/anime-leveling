local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local hotbarModule = require(script:WaitForChild("Hotbar"))

local Player = Players.LocalPlayer

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Requests = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Requests")
local Profile = Requests:InvokeServer("Profile")

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local humanoid = Character:WaitForChild("Humanoid")

local function UpdateHud(index: string, value: any)
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
		Level.Text = Profile.Level
		PlayerName.Text = Player.Name
		PlayerImage.Image =
			Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		Progress.Size = UDim2.fromScale(Profile.Experience / Profile.Level * 243, 1)
	end
end

UpdateHud()

local function OnDied()
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local Died = PlayerGui:WaitForChild("Died")
	local diedBackground = Died:WaitForChild("Background") :: Frame
	local diedTitle = diedBackground:WaitForChild("Title") :: TextLabel
	local diedRespawn = diedBackground:WaitForChild("Respawn") :: TextButton
	local diedRespawnStroke = diedRespawn:WaitForChild("UIStroke") :: UIStroke

	diedRespawn.Activated:Connect(function()
		Requests:InvokeServer("Respawn")
	end)

	Died.Enabled = true

	diedBackground.BackgroundTransparency = 1
	diedTitle.TextTransparency = 1
	diedRespawn.TextTransparency = 1
	diedRespawnStroke.Transparency = 1

	TweenService:Create(diedBackground, TweenInfo.new(1.2), {
		BackgroundTransparency = 0.3,
	}):Play()
	TweenService:Create(diedTitle, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.6), {
		TextTransparency = 0,
	}):Play()
	TweenService:Create(diedRespawn, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3), {
		TextTransparency = 0,
	}):Play()
	TweenService
		:Create(diedRespawnStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3), {
			Transparency = 0,
		})
		:Play()
end

humanoid.Died:Once(function()
	OnDied()
end)

Player.CharacterAdded:Connect(function(character)
	Character = character
	humanoid = character:WaitForChild("Humanoid")

	UpdateHud()
	hotbarModule:OrganizeHotbar(Profile)

	humanoid.Died:Connect(function()
		OnDied()
	end)
end)

local PlayerHud = ReplicatedStorage.Events:WaitForChild("PlayerHud") :: RemoteEvent
PlayerHud.OnClientEvent:Connect(function(name: string, value: any)
	UpdateHud(name, value)
end)
