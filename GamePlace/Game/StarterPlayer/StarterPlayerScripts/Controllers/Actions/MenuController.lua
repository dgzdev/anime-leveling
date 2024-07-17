local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local MenuController = Knit.CreateController({
	Name = "MenuController",
})

local CameraController
local HumanoidManagerController
local SettingsController

------------------------------------------------
-- Menu
------------------------------------------------
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local menu: SurfaceGui = playerGui:WaitForChild("menu")

------------------------------------------------
-- Variables
------------------------------------------------
local menuIsShowing = false
local shouldStepRunService = false
local runServiceSpeed = 7.5

local menuSize = Vector3.new(15, 10, 1)
local menuPart = Instance.new("Part", ReplicatedStorage)

menuPart.Size = menuSize
menuPart.Name = "MenuPart"
menuPart.Transparency = 1
menuPart.Anchored = true
menuPart.CanCollide = false
menuPart.Position = Vector3.new(3000, 3000, 3000)
menu.Adornee = menuPart

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local TargetCFrame = CFrame.new()
local menuIsTweening = false

local modifiedParts = {}

function MenuController.CreateRunService()
	RunService:BindToRenderStep("Menu", Enum.RenderPriority.Camera.Value, function(deltatime: number)
		if shouldStepRunService then
			workspace.CurrentCamera.CFrame =
				workspace.CurrentCamera.CFrame:Lerp(TargetCFrame, runServiceSpeed * deltatime)
		end
	end)
end

function MenuController.ShowDepthOfField()
	local DepthOfFieldEffect: DepthOfFieldEffect
	if game.Lighting:FindFirstChildWhichIsA("DepthOfFieldEffect") then
		DepthOfFieldEffect = game.Lighting:FindFirstChildWhichIsA("DepthOfFieldEffect")
	else
		DepthOfFieldEffect = Instance.new("DepthOfFieldEffect", game.Lighting)
	end

	DepthOfFieldEffect.Enabled = true

	TweenService:Create(DepthOfFieldEffect, TweenInfo.new(1), {
		FocusDistance = 0,
		InFocusRadius = 15,
		FarIntensity = 1,
		NearIntensity = 0,
	}):Play()
end
function MenuController.HideDepthOfField()
	local DepthOfFieldEffect: DepthOfFieldEffect
	if game.Lighting:FindFirstChildWhichIsA("DepthOfFieldEffect") then
		DepthOfFieldEffect = game.Lighting:FindFirstChildWhichIsA("DepthOfFieldEffect")
	else
		DepthOfFieldEffect = Instance.new("DepthOfFieldEffect", game.Lighting)
	end

	DepthOfFieldEffect.Enabled = true

	TweenService:Create(DepthOfFieldEffect, TweenInfo.new(1), {
		FocusDistance = 0,
		InFocusRadius = 250,
		FarIntensity = 0.3,
		NearIntensity = 0,
	}):Play()
end

function MenuController.ShowMenu()
	if menuIsTweening then
		return
	end
	menuIsTweening = true

	runServiceSpeed = 7.5
	CameraController:DisableCamera()

	MenuController.ShowDepthOfField()

	HumanoidManagerController:RunForAllHumanoidsExcept(function(humanoid: Humanoid)
		local parent = humanoid.Parent

		for _, bp: BasePart in parent:GetDescendants() do
			if bp:IsA("BasePart") then
				bp.LocalTransparencyModifier = 0.9
			end
		end
	end, Humanoid)

	for _, object: GuiObject in menu:GetDescendants() do
		if object:IsA("Frame") then
			local current = object.BackgroundTransparency
			object.BackgroundTransparency = 1
			TweenService:Create(object, TweenInfo.new(0.5), { BackgroundTransparency = current }):Play()
		elseif object.ClassName:find("Text") and not object.ClassName:find("UI") then
			local currentBackgroundTransparency = object.BackgroundTransparency
			local currentTextTransparency = object.TextTransparency

			object.BackgroundTransparency = 1
			object.TextTransparency = 1

			TweenService:Create(object, TweenInfo.new(0.5), {
				BackgroundTransparency = currentBackgroundTransparency,
				TextTransparency = currentTextTransparency,
			}):Play()
		elseif object.ClassName:find("Image") and not object.ClassName:find("UI") then
			local currentTransparency = object.ImageTransparency
			local currentBackgroundTransparency = object.BackgroundTransparency

			object.ImageTransparency = 1
			object.BackgroundTransparency = 1

			TweenService:Create(object, TweenInfo.new(0.5), {
				ImageTransparency = currentTransparency,
				BackgroundTransparency = currentBackgroundTransparency,
			}):Play()
		end
	end

	menuPart.Parent = workspace
	menuPart.CFrame = Humanoid.RootPart.CFrame * CFrame.new(7, 1.5, -3)

	local LookAt = CFrame.lookAt(Humanoid.RootPart.Position, menuPart.Position)

	Humanoid.RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	Humanoid.RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	local Animator: Animator = Humanoid:WaitForChild("Animator")
	for _, anim in Animator:GetPlayingAnimationTracks() do
		if anim.Name == "Idle" then
			continue
		end
		anim:Stop(0.5)
	end

	TargetCFrame = (Humanoid.RootPart.CFrame * CFrame.new(7, 2, 5))
	shouldStepRunService = true
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

	Humanoid.RootPart.Anchored = true

	local ovp = OverlapParams.new()
	ovp.FilterType = Enum.RaycastFilterType.Exclude
	ovp.FilterDescendantsInstances = { Character }
	local parts = workspace:GetPartBoundsInRadius(TargetCFrame.Position, 5, ovp)

	for _, part in menuPart:GetTouchingParts() do
		table.insert(modifiedParts, part)
		part.LocalTransparencyModifier = 1
	end
	for _, part in parts do
		table.insert(modifiedParts, part)
		part.LocalTransparencyModifier = 1
	end

	Humanoid.Parent:PivotTo(Humanoid.RootPart.CFrame * CFrame.Angles(0, math.rad(-20), 0))

	task.delay(0.6, function()
		menuIsTweening = false
	end)
end
function MenuController.HideMenu()
	if menuIsTweening then
		return
	end
	menuIsTweening = true

	MenuController.HideDepthOfField()
	for _, part in modifiedParts do
		part.LocalTransparencyModifier = 0
		modifiedParts[_] = nil
	end

	HumanoidManagerController:RunForAllHumanoidsExcept(function(humanoid: Humanoid)
		local parent = humanoid.Parent

		for _, bp: BasePart in parent:GetDescendants() do
			if bp:IsA("BasePart") then
				bp.LocalTransparencyModifier = 0
			end
		end
	end, Humanoid)

	local defaults = {}

	for _, object: GuiObject in menu:GetDescendants() do
		if object:IsA("Frame") then
			defaults[object] = { BackgroundTransparency = object.BackgroundTransparency }

			TweenService:Create(object, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		elseif object.ClassName:find("Text") and not object.ClassName:find("UI") then
			defaults[object] = {
				BackgroundTransparency = object.BackgroundTransparency,
				TextTransparency = object.TextTransparency,
			}

			TweenService:Create(object, TweenInfo.new(0.25), {
				BackgroundTransparency = 1,
				TextTransparency = 1,
			}):Play()
		elseif object.ClassName:find("Image") and not object.ClassName:find("UI") then
			defaults[object] = {
				ImageTransparency = object.ImageTransparency,
				BackgroundTransparency = object.BackgroundTransparency,
			}

			TweenService:Create(object, TweenInfo.new(0.25), {
				ImageTransparency = 1,
				BackgroundTransparency = 1,
			}):Play()
		end
	end

	runServiceSpeed = 15
	TargetCFrame = (Humanoid.RootPart.CFrame * CFrame.new(0, 1.5, 12.5))

	task.delay(0.25, function()
		menuPart.Parent = ReplicatedStorage
		menuPart.CFrame = CFrame.new(3000, 3000, 3000)

		shouldStepRunService = false
		Humanoid.RootPart.Anchored = false
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

		CameraController:EnableCamera()

		for object, props in defaults do
			for param: string, value: number in pairs(props) do
				object[param] = value
			end
		end

		task.wait(0.1)
		menuIsTweening = false
	end)
end

function MenuController.CreateContext()
	ContextActionService:BindAction("MenuShow", function(actionName, inputState, inputObject)
		if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
			return
		end

		if menuIsTweening then
			return
		end

		if inputState == Enum.UserInputState.Begin then
			if menuIsShowing then
				MenuController.HideMenu()
			else
				MenuController.ShowMenu()
			end

			menuIsShowing = not menuIsShowing
		end
	end, false, Enum.KeyCode.M)
end

function MenuController.DisableContext()
	ContextActionService:UnbindAction("MenuShow")
end

function MenuController.KnitStart()
	CameraController = Knit.GetController("CameraController")
	HumanoidManagerController = Knit.GetController("HumanoidManagerController")
	SettingsController = Knit.GetController("SettingsController")

	local Sections: Folder = menu:WaitForChild("Background"):WaitForChild("Sections")
	local SETTINGS: Frame = Sections:WaitForChild("SETTINGS")

	SettingsController:LoadSettings(SETTINGS)

	MenuController.CreateContext()
	MenuController.CreateRunService()

	Player.CharacterAdded:Connect(function(character)
		MenuController.DisableContext()
		RunService:UnbindFromRenderStep("Menu")

		Character = character
		Humanoid = Character:WaitForChild("Humanoid")
		TargetCFrame = CFrame.new()
		menuIsShowing = false
		shouldStepRunService = false

		MenuController.CreateContext()
		MenuController.CreateRunService()
	end)
end

return MenuController
