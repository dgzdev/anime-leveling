local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = ReplicatedFirst:WaitForChild("loadingScreen"):Clone()

local bg = screenGui:WaitForChild("Background")

local LoadingBar = bg:WaitForChild("LoadingBar")
local Value: Frame = LoadingBar:WaitForChild("Value")
local Assets: TextLabel = bg:WaitForChild("Assets")

Assets.Text = "0%"

local loadedAssets = 0
local assetsToLoad = 101

local function getpercentage()
	local n = loadedAssets / assetsToLoad
	n = math.clamp(n, 0, 1)
	return n
end

task.spawn(function()
	local Character = player.Character or player.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	repeat
		RootPart.Anchored = true
	until RootPart.Anchored == true

	while true do
		local n = getpercentage()
		TweenService:Create(Value, TweenInfo.new(0.45, Enum.EasingStyle.Cubic), {
			Size = UDim2.fromScale(n, 1),
		}):Play()
		task.wait(0.25)
		Assets.Text = tostring(math.floor(n * 100)) .. "%"
	end
end)

local loadingRing = bg:WaitForChild("LoadingIcon")

local skipButton = Instance.new("TextButton", screenGui)
skipButton.Size = UDim2.fromScale(0.15, 0.2)
skipButton.AnchorPoint = Vector2.new(0.5)
skipButton.Position = UDim2.fromScale(0.5, 0.6)
skipButton.BackgroundTransparency = 1
skipButton.Font = Enum.Font.GothamMedium

skipButton.TextColor3 = Color3.new(1, 1, 1)

skipButton.Text = "Skip"
skipButton.TextSize = 24
skipButton.Visible = false

-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

screenGui.Parent = playerGui

local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
local tween = TweenService:Create(loadingRing, tweenInfo, { Rotation = 360 })
tween:Play()

TweenService:Create(loadingRing, TweenInfo.new(1.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true, 0), {
	ImageTransparency = 0.9,
}):Play()

local start = tick()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

task.delay(20, function()
	skipButton.Visible = true
end)

local assets = SoundService:GetDescendants()
for _, a in ipairs(Workspace:GetDescendants()) do
	if a:IsA("Sound") then
		table.insert(assets, a)
	end
end
ContentProvider:PreloadAsync(assets, function()
	loadedAssets += 1
	task.wait()
end)

skipButton.Activated:Connect(function(inputObject, clickCount)
	screenGui:Destroy()
	print("[Loading] Skipped loading screen. (Took " .. math.floor(tick() - start) .. " seconds.)")
	script:Destroy()
end)

local endTick = tick()

screenGui:Destroy()
print("[Loading] Loaded in " .. math.floor(endTick - start) .. " seconds.")
print(loadedAssets)
script:Destroy()
