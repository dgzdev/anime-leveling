local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "loadingScreen"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

task.spawn(function()
	local Character = player.Character or player.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	repeat
		RootPart.Anchored = true
	until RootPart.Anchored == true
end)

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
textLabel.Font = Enum.Font.GothamMedium
textLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.Position = UDim2.fromScale(0.5, 0.5)
textLabel.Text = "Loading"
textLabel.TextSize = 28
textLabel.Parent = screenGui

local loadingRing = Instance.new("ImageLabel")
loadingRing.Size = UDim2.new(0, 256, 0, 256)
loadingRing.BackgroundTransparency = 1
loadingRing.Image = "rbxassetid://4965945816"
loadingRing.AnchorPoint = Vector2.new(0.5, 0.5)
loadingRing.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingRing.Parent = screenGui

local skipButton = Instance.new("TextButton", screenGui)
skipButton.Size = UDim2.new(0, 100, 0, 50)
skipButton.AnchorPoint = Vector2.new(0.5)
skipButton.Position = UDim2.fromScale(0.5, 0.85)
skipButton.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
skipButton.Font = Enum.Font.GothamMedium
skipButton.TextColor3 = Color3.new(0.8, 0.8, 0.8)
skipButton.Text = "Skip"
skipButton.TextSize = 24
skipButton.Visible = false

-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
local tween = TweenService:Create(loadingRing, tweenInfo, { Rotation = 360 })
tween:Play()

local start = tick()

task.wait(5) -- Force screen to appear for a minimum number of seconds

if not game:IsLoaded() then
	game.Loaded:Wait()
end

skipButton.Visible = true

skipButton.Activated:Connect(function(inputObject, clickCount)
	screenGui:Destroy()
	print("[Loading] Skipped loading screen. (Took " .. math.floor(tick() - start) .. " seconds.)")
end)

ContentProvider:PreloadAsync(game:GetDescendants())

local endTick = tick()

screenGui:Destroy()
print("[Loading] Loaded in " .. math.floor(endTick - start) .. " seconds.")
