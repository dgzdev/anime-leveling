local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GamepadService = game:GetService("GamepadService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CustomizationGui: ScreenGui = StarterGui:WaitForChild("CharacterCustomization"):Clone()
local MainMenu: ScreenGui = StarterGui:WaitForChild("MainMenu"):Clone()
local Vignette: ScreenGui = StarterGui:WaitForChild("Vignette"):Clone()
local PressAnyKey: ScreenGui = StarterGui:WaitForChild("PressAnyKey"):Clone()
local SlotSelection = StarterGui:WaitForChild("SlotSelection"):Clone()

MainMenu.Parent = PlayerGui
CustomizationGui.Parent = PlayerGui
Vignette.Parent = PlayerGui

local Knit = require(game.ReplicatedStorage.Packages.Knit)
Knit.Start({ ServicePromises = false }):await()

local title1: ImageLabel = PressAnyKey:WaitForChild("Logo")
local pressanykey: TextLabel = PressAnyKey:WaitForChild("pressanykey")

require(script.Parent:WaitForChild("UI")):Init()

local MenuCamera = require(ReplicatedStorage:WaitForChild("MenuCamera"))

local hasPressedButton = false

local ViewPart: BasePart = Workspace:WaitForChild("CameraParts"):WaitForChild("View")

local CharacterPart: BasePart = Workspace:WaitForChild("CameraParts"):WaitForChild("Character")

local Requests = ReplicatedStorage:WaitForChild("Request")

local function UpdateSlots()
	local Data = Requests:InvokeServer("Slots")
	local Slots = SlotSelection:WaitForChild("LeftSide"):WaitForChild("Slots")

	for slotNumber, slotData in pairs(Data.Slots) do
		local Slot: Frame = Slots:WaitForChild("Slot" .. slotNumber)

		if slotData == "false" then
			Slot.Visible = false
			Slots:WaitForChild("SlotCreation").Visible = true
			continue
		end

		local Number: TextLabel = Slot:WaitForChild("Number")
		local SlotN: TextLabel = Slot:WaitForChild("SlotN")
		local Desc: TextLabel = Slot:WaitForChild("Desc")
		local Stroke: Frame = Slot:WaitForChild("Stroke")
		local UIStroke: UIStroke = Stroke:WaitForChild("UIStroke")

		if slotNumber == Data.Selected_Slot then
			Slot.BackgroundColor3 = Color3.fromRGB(229, 193, 102)
			Desc.TextColor3 = Color3.fromRGB(55, 57, 90)
			SlotN.TextColor3 = Color3.fromRGB(55, 57, 90)
			Number.TextColor3 = Color3.fromRGB(55, 57, 90)

			UIStroke.Color = Color3.fromRGB(38, 44, 77)
		else
			Slot.BackgroundColor3 = Color3.fromRGB(55, 57, 90)
			Desc.TextColor3 = Color3.fromRGB(241, 239, 255)
			SlotN.TextColor3 = Color3.fromRGB(241, 239, 255)
			Number.TextColor3 = Color3.fromRGB(241, 239, 255)

			UIStroke.Color = Color3.fromRGB(55, 57, 90)
		end

		Number.Text = slotData.LastJoin or os.date("%x")
		SlotN.Text = "Slot " .. (slotNumber or 1)
		Desc.Text = slotData.Location or "Character Creation"
	end
end

UpdateSlots()

local function SlideIn()
	local RightSide = SlotSelection:WaitForChild("RightSide")
	local LeftSide = SlotSelection:WaitForChild("LeftSide")
	local Mid = SlotSelection:WaitForChild("Mid")

	local OriginalPositions = {
		["R"] = UDim2.fromScale(RightSide.Position.X.Scale, RightSide.Position.Y.Scale),
		["L"] = UDim2.fromScale(LeftSide.Position.X.Scale, LeftSide.Position.Y.Scale),
		["M"] = UDim2.fromScale(Mid.Position.X.Scale, Mid.Position.Y.Scale),
	}

	RightSide.Position = UDim2.fromScale(1 + RightSide.Size.X.Scale, 0.5)
	LeftSide.Position = UDim2.fromScale(-LeftSide.Size.X.Scale, 0.5)
	Mid.Position = UDim2.fromScale(0.5, 1 + Mid.Size.Y.Scale)

	task.wait(0.25)
	SlotSelection.Enabled = true

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.25)

	local tween = TweenService:Create(RightSide, tweenInfo, { Position = OriginalPositions.R })
	tween:Play()
	tween = TweenService:Create(LeftSide, tweenInfo, { Position = OriginalPositions.L })
	tween:Play()
	tween = TweenService:Create(Mid, tweenInfo, { Position = OriginalPositions.M })
	tween:Play()
end

local function fadeIn()
	local sound1 = SoundService:WaitForChild("Music"):WaitForChild("desolateSting")
	sound1.Ended:Once(function(soundId)
		SoundService:WaitForChild("Music"):WaitForChild("desolate"):Play()
	end)
	sound1:Play()

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 1)
	local tween = TweenService:Create(title1, tweenInfo, { ImageTransparency = 0 })
	tween:Play()
	tween = TweenService:Create(pressanykey, tweenInfo, { TextTransparency = 0 })
	tween:Play()
	tween.Completed:Wait()

	local infiniteTween = TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)
	tween = TweenService:Create(pressanykey, infiniteTween, { TextTransparency = 0.9 })
	tween:Play()
end

local function SetUpCustomization()
	local TweenStyle = TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.8)
	local tw = TweenService:Create(Workspace.CurrentCamera, TweenStyle, {
		CFrame = CharacterPart.CFrame,
		FieldOfView = 90,
	})
	tw:Play()
	tw.Completed:Wait()

	MenuCamera:SetCF(Workspace.CurrentCamera.CFrame)
	MenuCamera:Enable()

	SlideIn()
end

local function SlideInMain1()
	local PlayerGui = Player.PlayerGui
	local Main1Frame = PlayerGui.MainMenu:WaitForChild("Background1") :: Frame
	local ActualPos = Main1Frame.Position :: UDim2

	if UserInputService.GamepadEnabled then
		GamepadService:EnableGamepadCursor(Main1Frame)
	end

	Main1Frame.Position = UDim2.fromScale(-1, ActualPos.Y.Scale)

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.25)

	TweenService:Create(Main1Frame, tweenInfo, { Position = ActualPos }):Play()
	Main1Frame.Visible = true
end

local function fadeOut()
	hasPressedButton = true

	SoundService:WaitForChild("SFX"):WaitForChild("button.wav"):Play()

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0.25)
	local tween = TweenService:Create(title1, tweenInfo, { ImageTransparency = 1 })
	tween:Play()

	tween = TweenService:Create(pressanykey, tweenInfo, { TextTransparency = 1 })
	tween:Play()

	tween.Completed:Wait()

	PressAnyKey.Enabled = false

	SlideInMain1()
end

local function onInputBegan(input)
	MenuCamera:Disable()

	if hasPressedButton then
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		fadeOut()
	elseif input.UserInputType == Enum.UserInputType.Touch then
		fadeOut()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		fadeOut()
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		fadeOut()
	end
end

SlotSelection.Parent = PlayerGui

SlotSelection.Enabled = false

if not game:GetAttribute("Loaded") then
	game:GetAttributeChangedSignal("Loaded"):Wait()
end

CharacterPart.Anchored = true

task.wait()

local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = ViewPart.CFrame

MenuCamera:SetCF(Workspace.CurrentCamera.CFrame)
MenuCamera:Enable()

PressAnyKey.Parent = PlayerGui

PressAnyKey.Enabled = true

UserInputService.InputBegan:Connect(onInputBegan)

title1.ImageTransparency = 1
pressanykey.TextTransparency = 1

UserInputService.GamepadDisconnected:Connect(function(gamepadNum)
	if GamepadService.GamepadCursorEnabled then
		GamepadService:DisableGamepadCursor()
	end
end)

fadeIn()
