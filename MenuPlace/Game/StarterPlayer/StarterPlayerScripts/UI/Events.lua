local Events = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")

local Start = ReplicatedStorage:WaitForChild("Start")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local ClothingService = Knit.GetService("ClothingService")
local PlayerService = Knit.GetService("PlayerService")

local ColorPickerModule = require(game.ReplicatedStorage.Color)

local function SlideInMain2()
	local PlayerGui = Player.PlayerGui
	local Main1Frame = PlayerGui.MainMenu:WaitForChild("Background2") :: Frame
	local ActualPos = Main1Frame.Position :: UDim2

	Main1Frame.Position = UDim2.fromScale(-1, ActualPos.Y.Scale)

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false)

	TweenService:Create(Main1Frame, tweenInfo, { Position = ActualPos }):Play()
	Main1Frame.Visible = true
end

local function SlideOutMain1()
	local PlayerGui = Player.PlayerGui
	local Main1Frame = PlayerGui.MainMenu:WaitForChild("Background1") :: Frame
	local ActualPos = Main1Frame.Position :: UDim2

	if UserInputService.GamepadEnabled then
		GamepadService:EnableGamepadCursor(Main1Frame)
	end

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false)

	local a = TweenService:Create(Main1Frame, tweenInfo, { Position = UDim2.fromScale(-1, ActualPos.Y.Scale) })

	a:Play()
	a.Completed:Wait()

	Main1Frame.Position = ActualPos

	Main1Frame.Visible = false
end

local function SlideInMain1()
	local PlayerGui = Player.PlayerGui
	local Main1Frame = PlayerGui.MainMenu:WaitForChild("Background1") :: Frame
	local ActualPos = Main1Frame.Position :: UDim2

	if UserInputService.GamepadEnabled then
		GamepadService:EnableGamepadCursor(Main1Frame)
	end

	Main1Frame.Position = UDim2.fromScale(-1, ActualPos.Y.Scale)

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false)

	TweenService:Create(Main1Frame, tweenInfo, { Position = ActualPos }):Play()
	Main1Frame.Visible = true
end

local function SlideOut()
	local SlotSelection = PlayerGui:WaitForChild("SlotSelection")
	local RightSide = SlotSelection:WaitForChild("RightSide")
	local LeftSide = SlotSelection:WaitForChild("LeftSide")
	local Mid = SlotSelection:WaitForChild("Mid")

	local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.25)

	local tween =
		TweenService:Create(RightSide, tweenInfo, { Position = UDim2.fromScale(1 + RightSide.Size.X.Scale, 0.5) })
	tween:Play()
	tween = TweenService:Create(LeftSide, tweenInfo, { Position = UDim2.fromScale(-LeftSide.Size.X.Scale, 0.5) })
	tween:Play()
	tween = TweenService:Create(Mid, tweenInfo, { Position = UDim2.fromScale(0.5, 1 + Mid.Size.Y.Scale) })
	tween:Play()
	tween.Completed:Wait()
end

local function fadeInLoading(loadingGui: ScreenGui)
	local Background: Frame = loadingGui:WaitForChild("Background")
	local portal: ImageLabel = Background:WaitForChild("portal")
	local title: TextLabel = Background:WaitForChild("title")

	Background.Position = UDim2.fromScale(0, -1)

	loadingGui.Enabled = true

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut, 0, false, 0.25)
	local infiniteTween = TweenService:Create(
		portal,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
		{ Rotation = 360 }
	)
	infiniteTween:Play()
	TweenService:Create(Background, tweenInfo, { Position = UDim2.fromScale(0, 0) }):Play()
end

local Requests = ReplicatedStorage:WaitForChild("Request")

local CharacterCustomization: ScreenGui = PlayerGui:WaitForChild("CharacterCustomization")
local RightSide: Frame = CharacterCustomization:WaitForChild("RightSide")
local LeftSide: Frame = CharacterCustomization:WaitForChild("LeftSide")
local Mid: Frame = CharacterCustomization:WaitForChild("Mid")

local customization = ClothingService:GetClothingData(Player)

local MenuCamera = require(ReplicatedStorage:WaitForChild("MenuCamera"))

local Character = Workspace:WaitForChild("Characters"):WaitForChild("Rig")

local activeFrame = "Hair"

function CheckTableEquality(t1, t2)
	for i, v in pairs(t1) do
		if t2[i] ~= v then
			return false
		end
	end
	for i, v in pairs(t2) do
		if t1[i] ~= v then
			return false
		end
	end
	return true
end

Events.ButtonDown = {
	["TurnRight"] = function()
		local ratePerSecond = 90
		RunService:BindToRenderStep("TurnRight", Enum.RenderPriority.Input.Value, function(delta: number)
			Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(ratePerSecond * delta), 0)
		end)
	end,
	["TurnLeft"] = function()
		local ratePerSecond = 90
		RunService:BindToRenderStep("TurnLeft", Enum.RenderPriority.Input.Value, function(delta: number)
			Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(-(ratePerSecond * delta)), 0)
		end)
	end,
}

Events.ButtonUp = {
	["TurnRight"] = function()
		RunService:UnbindFromRenderStep("TurnRight")
	end,
	["TurnLeft"] = function()
		RunService:UnbindFromRenderStep("TurnLeft")
	end,
}

Events.Buttons = {
	["SetActive"] = function(Gui: GuiButton)
		for index, value in ipairs(Gui.Parent.Parent:GetChildren()) do
			if value:IsA("Frame") then
				value:SetAttribute("Active", false)
			end
		end
		Gui.Parent:SetAttribute("Active", true)
		activeFrame = Gui.Parent.Name
	end,

	["Teleport"] = function(Gui: GuiButton)
		local Slot = Gui:GetAttribute("SlotNumber")
		local profile = PlayerService:GetProfile(Player)

		PlayerService:ChangeSelectedSlot(Slot)

		local Loading = StarterGui:WaitForChild("Loading"):Clone()
		Loading.Parent = PlayerGui

		fadeInLoading(Loading)

		Start:FireServer()
	end,

	["Play"] = function(Gui: GuiButton)
		SlideOutMain1()
		SlideInMain2()

		local profile = PlayerService:GetProfile(Player)
		if not profile then
			return game.Players.LocalPlayer:Kick(
				"Profile Error, Please, Rejoin (If you think this is a bug, please, contact the developers)"
			)
		end
		print(profile)

		for slotNumber, slotData in profile.Slots do
			local slotFrame = PlayerGui.MainMenu.Background2:WaitForChild("Slot" .. slotNumber)

			if slotData ~= "false" then
				slotFrame.Description.Text = `Last Join: {slotData.LastJoin}`
				slotFrame.Title.Text = `LvL: {slotData.Data.Level}`
			else
				slotFrame.Description.Text = `Create a new character`
				slotFrame.Title.Text = `SLOT #{slotNumber}`
			end
		end

		--local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		--local head: BasePart = c:WaitForChild("Head")
		--
		--MenuCamera.CF0 = Workspace.CurrentCamera.CFrame
		--MenuCamera:Disable()
		--
		--SlideOut()
		--
		--local camera = Workspace.CurrentCamera
		--
		--local portalPosition = Workspace:WaitForChild("CharacterPortalPosition")
		--
		--task.spawn(function()
		--	while true do
		--		local distance = (head.Position - portalPosition.Position).Magnitude
		--		if distance < 30 then
		--			local Loading = StarterGui:WaitForChild("Loading"):Clone()
		--			Loading.Parent = PlayerGui
		--
		--			fadeInLoading(Loading)
		--
		--			break
		--		end
		--		RunService.RenderStepped:Wait()
		--	end
		--end)
		--
		--local camera = Workspace.CurrentCamera
		--RunService:BindToRenderStep("Camera", Enum.RenderPriority.Last.Value, function()
		--	local position = head.CFrame * CFrame.new(0, 0, 3)
		--	local cframe = CFrame.lookAt(position.Position, head.Position)
		--	camera.CFrame = camera.CFrame:Lerp(cframe, 0.5)
		--end)
		--
		--Start:FireServer()
	end,

	["CreateSlot"] = function()
		print("createslot")
	end,

	["Rotate"] = function()
		--Requests:InvokeServer("RotateCharacter")
	end,
	["Left"] = function(Gui: GuiButton)
		local object = Gui.Parent.Name
		local number: TextLabel = Gui.Parent:WaitForChild("Number")
		print(object)
		if tonumber(number.Text) == 0 then
			return
		end

		local Response
		if object == "Shirt" then
			Response = ClothingService:UpdateShirt(tonumber(number.Text) - 1)
		elseif object == "Pants" then
			Response = ClothingService:UpdatePants(tonumber(number.Text) - 1)
		elseif object == "Shoes" then
			Response = ClothingService:UpdateShoes(tonumber(number.Text) - 1)
		elseif object == "Hair" then
			Response = ClothingService:UpdateHair(tonumber(number.Text) - 1)
		end

		for index, value in ipairs(Gui.Parent.Parent:GetChildren()) do
			if value:IsA("Frame") then
				value:SetAttribute("Active", false)
			end
		end
		Gui.Parent:SetAttribute("Active", true)
		activeFrame = Gui.Parent.Name

		if Response ~= false then
			number.Text = tonumber(number.Text) - 1
		end
	end,

	["Right"] = function(Gui: GuiButton)
		local object = Gui.Parent.Name
		local number: TextLabel = Gui.Parent:WaitForChild("Number")

		print(object)

		local Response
		if object == "Shirt" then
			Response = ClothingService:UpdateShirt(tonumber(number.Text) + 1)
		elseif object == "Pants" then
			Response = ClothingService:UpdatePants(tonumber(number.Text) + 1)
		elseif object == "Shoes" then
			Response = ClothingService:UpdateShoes(tonumber(number.Text) + 1)
		elseif object == "Hair" then
			Response = ClothingService:UpdateHair(tonumber(number.Text) + 1)
		end

		for index, value in ipairs(Gui.Parent.Parent:GetChildren()) do
			if value:IsA("Frame") then
				value:SetAttribute("Active", false)
			end
		end
		Gui.Parent:SetAttribute("Active", true)
		activeFrame = Gui.Parent.Name

		if Response ~= false then
			number.Text = tonumber(number.Text) + 1
		end
	end,

	["Save"] = function(Gui: GuiButton)
		local function slideOut()
			CharacterCustomization.Enabled = true

			local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.25)

			local tween = TweenService:Create(
				RightSide,
				tweenInfo,
				{ Position = UDim2.fromScale(1 + RightSide.Size.X.Scale, 0.5) }
			)
			tween:Play()
			tween =
				TweenService:Create(LeftSide, tweenInfo, { Position = UDim2.fromScale(-LeftSide.Size.X.Scale, 0.5) })
			tween:Play()
			tween = TweenService:Create(Mid, tweenInfo, { Position = UDim2.fromScale(0.5, 1 + Mid.Size.Y.Scale) })
			tween:Play()
			tween.Completed:Wait()

			MenuCamera.CF0 = Workspace.CurrentCamera.CFrame
			MenuCamera:Disable()

			CharacterCustomization.Enabled = false

			local ClothingInfo = {}

			for i, v in pairs(workspace.Characters.Rig.Clothes:GetChildren()) do
				for j, k in pairs(v:GetDescendants()) do
					if k:IsA("BasePart") and k:GetAttribute("CanColor") then
						ClothingInfo[v.Name] = k.Color
						break
					end
				end
			end

			-->
			ClothingService:SaveClothingColors(ClothingInfo)
		end

		slideOut()

		local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		local head: BasePart = c:WaitForChild("Head")

		TweenService:Create(
			Workspace.CurrentCamera,
			TweenInfo.new(0.25),
			{ CFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 1.5) }
		):Play()

		local portalPosition = Workspace:WaitForChild("CharacterPortalPosition")

		task.spawn(function()
			while true do
				local distance = (head.Position - portalPosition.Position).Magnitude
				if distance < 30 then
					local Loading = StarterGui:WaitForChild("Loading"):Clone()
					Loading.Parent = PlayerGui

					fadeInLoading(Loading)

					break
				end
				task.wait()
			end
		end)

		Start:FireServer()
		local camera = Workspace.CurrentCamera
		RunService:BindToRenderStep("Camera", Enum.RenderPriority.Last.Value, function()
			local position = head.CFrame * CFrame.new(0, 0, 3)
			local cframe = CFrame.lookAt(position.Position, head.Position)
			camera.CFrame = camera.CFrame:Lerp(cframe, 0.5)
		end)
	end,

	["Edit"] = function(Gui: GuiButton)
		--* isso aqui e quando vc clica no botão pra editar, da uma lida q vc vai chegar onde eu to codando ali
		SlideOut()
		local a = TweenService:Create(
			Workspace.CurrentCamera,
			TweenInfo.new(0.25),
			{ CFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 1.5) }
		)

		local function SlideIn()
			local OriginalPositions = {
				["R"] = UDim2.fromScale(RightSide.Position.X.Scale, RightSide.Position.Y.Scale),
				["L"] = UDim2.fromScale(LeftSide.Position.X.Scale, LeftSide.Position.Y.Scale),
				["M"] = UDim2.fromScale(Mid.Position.X.Scale, Mid.Position.Y.Scale),
			}

			RightSide.Position = UDim2.fromScale(1 + RightSide.Size.X.Scale, 0.5)
			LeftSide.Position = UDim2.fromScale(-LeftSide.Size.X.Scale, 0.5)
			Mid.Position = UDim2.fromScale(0.5, -Mid.Size.Y.Scale)

			CharacterCustomization.Enabled = true

			local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.25)

			local tween = TweenService:Create(RightSide, tweenInfo, { Position = OriginalPositions.R })
			tween:Play()
			tween = TweenService:Create(LeftSide, tweenInfo, { Position = OriginalPositions.L })
			tween:Play()
			tween = TweenService:Create(Mid, tweenInfo, { Position = OriginalPositions.M })
			tween:Play()
		end
		a:Play()
		a.Completed:Wait()
		SlideIn()
	end,
	["Close"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
	end,
	["Default"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIClick"):Play()
	end,
}
Events.Hover = {
	["Scale"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()

		local scale = Gui:FindFirstChildWhichIsA("UIScale", true)
		if not scale then
			scale = Gui.Parent:FindFirstChildWhichIsA("UIScale", true)
		end

		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		TweenService:Create(scale, tweenInfo, { Scale = 1.2 }):Play()
	end,

	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end

		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,
}
Events.Leave = {
	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end

		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,
	["Scale"] = function(Gui: GuiButton)
		local scale = Gui:FindFirstChildWhichIsA("UIScale", true)
		if not scale then
			scale = Gui.Parent:FindFirstChildWhichIsA("UIScale", true)
		end

		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		TweenService:Create(scale, tweenInfo, { Scale = 1 }):Play()
	end,
}

local Picker = ColorPickerModule.New(CharacterCustomization, {
	Position = UDim2.fromScale(0.65, 0.3),
})

Picker.Updated:Connect(function(color: Color3)
	local Rig = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
	-- Fired every time the color changes

	--[[
		activeFrame: string | "Hair", "Shirt", "Pants", "Shoes"
	]]
	if not Rig.Clothes[activeFrame] then
		return
	end

	for i, v in pairs(Rig.Clothes[activeFrame]:GetDescendants()) do
		if v:IsA("BasePart") and v:GetAttribute("CanColor") then
			v.Color = color
		end
	end

	--print(color)
end)

return Events
