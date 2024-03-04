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

local customization: { List: {}, Selected: {}, [string]: number } = Requests:InvokeServer("Customization")

local MenuCamera = require(ReplicatedStorage:WaitForChild("MenuCamera"))

local function UpdateSlots()
	task.spawn(function()
		for _, object in ipairs(LeftSlots:GetChildren()) do
			if customization.List[object.Name] then
				local p = customization.List[object.Name]
				local min: NumberValue, max: NumberValue = object:WaitForChild("Min"), object:WaitForChild("Max")

				min.Value = 0
				max.Value = #p

				for i, v in pairs(customization.List[object.Name]) do
					if v == customization["Selected"][object.Name] then
						object:WaitForChild("Number").Text = tostring(i)
					else
						object:WaitForChild("Number").Text = "1"
					end
				end
			end
		end
		for _, object in ipairs(RightSlots:GetChildren()) do
			if customization.List[object.Name] then
				local p = customization.List[object.Name]
				local min: NumberValue, max: NumberValue = object:WaitForChild("Min"), object:WaitForChild("Max")

				min.Value = 0
				max.Value = #p

				for i, v in pairs(customization.List[object.Name]) do
					if v == customization["Selected"][object.Name] then
						object:WaitForChild("Number").Text = tostring(i)
					else
						object:WaitForChild("Number").Text = "1"
					end
				end
			end
		end
	end)
end

UpdateSlots()

local Character = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

local function ApplyHumanoidDescription()
	--> isso aq vai atualizar o humanoid pro novo acessorio q o player escolheu
	Requests:InvokeServer("UpdateHumanoidDescription", customization["Selected"])
end

local lastSelected = table.clone(customization["Selected"])
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

task.spawn(function()
	while true do
		local newSelected = customization["Selected"]

		if not CheckTableEquality(lastSelected, newSelected) then
			ApplyHumanoidDescription()
			lastSelected = table.clone(newSelected)
		end

		task.wait(0.25)
	end
end)

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
		local number: TextLabel = Gui.Parent:WaitForChild("Number")

		local min: NumberValue = Gui.Parent:WaitForChild("Min")
		local max: NumberValue = Gui.Parent:WaitForChild("Max")
		local current = math.clamp(tonumber(number.Text) - 1, min.Value, max.Value)

		number.Text = tostring(current)

		if current == 0 then
			customization["Selected"][Gui.Parent.Name] = 0
		else
			customization["Selected"][Gui.Parent.Name] = customization.List[Gui.Parent.Name][current]
		end
	end,

	["Right"] = function(Gui: GuiButton)
		local number: TextLabel = Gui.Parent:WaitForChild("Number")

		local min: NumberValue = Gui.Parent:WaitForChild("Min")
		local max: NumberValue = Gui.Parent:WaitForChild("Max")
		local current = math.clamp(tonumber(number.Text) + 1, min.Value, max.Value)

		number.Text = tostring(current)

		if current == 0 then
			customization["Selected"][Gui.Parent.Name] = 0
		else
			customization["Selected"][Gui.Parent.Name] = customization.List[Gui.Parent.Name][current]
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

local Request = ReplicatedStorage:WaitForChild("Request")
local customization = Request:InvokeServer("Customization")

return Events
