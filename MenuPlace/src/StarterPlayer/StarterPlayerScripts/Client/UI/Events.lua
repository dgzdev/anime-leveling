local Events = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Start = ReplicatedStorage:WaitForChild("Start")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
Knit.Start({ ServicePromises = false }):await()

local ClothingService = Knit.GetService("ClothingService")

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

local camera = Workspace.CurrentCamera

local CharacterCustomization: ScreenGui = PlayerGui:WaitForChild("CharacterCustomization")
local RightSide: Frame = CharacterCustomization:WaitForChild("RightSide")
local LeftSide: Frame = CharacterCustomization:WaitForChild("LeftSide")
local Mid: Frame = CharacterCustomization:WaitForChild("Mid")

local LeftSlots: Frame = LeftSide:WaitForChild("Slots")
local RightSlots: Frame = RightSide:WaitForChild("Slots")

local customization = ClothingService:GetClothingData(Player)

local MenuCamera = require(ReplicatedStorage:WaitForChild("MenuCamera"))

local Character = Workspace:WaitForChild("Characters"):WaitForChild("Rig")

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

Events.Buttons = {
	["Play"] = function()
		local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		local head: BasePart = c:WaitForChild("Head")

		MenuCamera.CF0 = Workspace.CurrentCamera.CFrame
		MenuCamera:Disable()

		SlideOut()

		RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, function()
			camera.CFrame = camera.CFrame:Lerp(CFrame.new(head.Position + Vector3.new(5, 0, 0), head.Position), 0.1)
		end)

		local portalPosition = Workspace:WaitForChild("CharacterPortalPosition")

		task.spawn(function()
			while true do
				local distance = (head.Position - portalPosition.Position).Magnitude
				if distance < 30 then
					local Loading = StarterGui:WaitForChild("Loading"):Clone()
					Loading.Parent = PlayerGui

					fadeInLoading(Loading)
					RunService:UnbindFromRenderStep("Camera")

					break
				end
				task.wait()
			end
		end)

		Start:FireServer()
	end,

	["CreateSlot"] = function()
		print("createslot")
	end,

	["Rotate"] = function()
		Requests:InvokeServer("RotateCharacter")
	end,

	["Left"] = function(Gui: GuiButton)
		local object = Gui.Parent.Name
		local number: TextLabel = Gui.Parent:WaitForChild("Number")

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
		end

		if Response ~= false then
			number.Text = tonumber(number.Text) - 1
		end
	end,

	["Right"] = function(Gui: GuiButton)
		local object = Gui.Parent.Name
		local number: TextLabel = Gui.Parent:WaitForChild("Number")

		local Response
		if object == "Shirt" then
			Response = ClothingService:UpdateShirt(tonumber(number.Text) + 1)
		elseif object == "Pants" then
			Response = ClothingService:UpdatePants(tonumber(number.Text) + 1)
		elseif object == "Shoes" then
			Response = ClothingService:UpdateShoes(tonumber(number.Text) + 1)
		end

		if Response ~= false then
			number.Text = tonumber(number.Text) + 1
		end
	end,

	["Save"] = function(Gui: GuiButton)
		Requests:InvokeServer("SaveCharacter")

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
		end

		slideOut()

		local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		local head: BasePart = c:WaitForChild("Head")

		TweenService:Create(
			Workspace.CurrentCamera,
			TweenInfo.new(0.25),
			{ CFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, 1.5) }
		):Play()

		RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, function()
			camera.CFrame = camera.CFrame:Lerp(CFrame.new(head.Position + Vector3.new(5, 0, 0), head.Position), 0.1)
		end)

		local portalPosition = Workspace:WaitForChild("CharacterPortalPosition")

		task.spawn(function()
			while true do
				local distance = (head.Position - portalPosition.Position).Magnitude
				if distance < 30 then
					local Loading = StarterGui:WaitForChild("Loading"):Clone()
					Loading.Parent = PlayerGui

					fadeInLoading(Loading)
					RunService:UnbindFromRenderStep("Camera")

					break
				end
				task.wait()
			end
		end)

		Start:FireServer()
	end,

	["Edit"] = function(Gui: GuiButton)
		--> isso aqui e quando vc clica no botão pra editar, da uma lida q vc vai chegar onde eu to codando ali
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
		MenuCamera.CF0 = Workspace.CurrentCamera.CFrame
		MenuCamera:Enable()
	end,
	["Close"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
	end,
	["Default"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIClick"):Play()
	end,
}
Events.Hover = {
	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end

		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,
}

return Events
