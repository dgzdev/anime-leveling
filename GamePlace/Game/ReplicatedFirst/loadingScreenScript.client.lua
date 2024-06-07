local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--teste

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui: ScreenGui = ReplicatedFirst:WaitForChild("loadingScreen"):Clone()

local sound = ReplicatedFirst:WaitForChild("desolate")
sound:Play()

local bg = screenGui:WaitForChild("Background")

local LoadingBar = bg:WaitForChild("LoadingBar")
local Value: Frame = LoadingBar:WaitForChild("Value")
local Assets: TextLabel = bg:WaitForChild("Assets")

Assets.Text = "0/0"

local function FadeOut()
	TweenService:Create(Value, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0), {
		Size = UDim2.fromScale(1, 1),
	}):Play()

	game:SetAttribute("Loaded", true)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
	local tween = TweenService:Create(bg, tweenInfo, {
		Position = UDim2.fromScale(0, 1),
	})

	TweenService:Create(sound, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0), {
		Volume = 0,
	}):Play()

	tween:Play()
	tween.Completed:Wait()
	bg.Visible = false
	screenGui:Destroy()
	script:Destroy()
end

task.spawn(function()
	local Character = player.Character or player.CharacterAdded:Wait()
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	repeat
		RootPart.Anchored = true
	until RootPart.Anchored == true
end)

local skipButton = Instance.new("TextButton")
skipButton.Size = UDim2.fromScale(0.15, 0.2)
skipButton.AnchorPoint = Vector2.new(0, 0)
skipButton.Position = UDim2.fromScale(0.1, 0.7)
skipButton.BackgroundTransparency = 1
skipButton.Font = Enum.Font.GothamMedium
skipButton.ZIndex = 10

skipButton.TextColor3 = Color3.new(1, 1, 1)

skipButton.Text = "Skip"
skipButton.TextSize = 36
skipButton.Visible = false

screenGui.Parent = playerGui
ReplicatedFirst:RemoveDefaultLoadingScreen()

local start = tick()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

task.delay(5, function()
	skipButton.Parent = bg
	skipButton.Visible = true
end)

skipButton.Activated:Connect(function(inputObject, clickCount)
	print("[Loading] Skipped loading screen. (Took " .. math.floor(tick() - start) .. " seconds.)")
	FadeOut()
end)

local assets = game:GetDescendants()

local totalAssets = #assets
local loadedAssets = 0

local function calc(): number
	return math.clamp(loadedAssets / totalAssets, 0, 1)
end

Assets.Text = `0/{totalAssets}`
Value:TweenSize(UDim2.fromScale(calc(), 1))

for _index, asset in assets do
	ContentProvider:PreloadAsync({ asset })
	loadedAssets += 1

	if screenGui.Enabled == false then
		break
	end

	Assets.Text = `{loadedAssets}/{totalAssets}`
	Value:TweenSize(UDim2.fromScale(calc(), 1))
end

local endTick = tick()

print("[Loading] Loaded in " .. math.floor(endTick - start) .. " seconds.")
FadeOut()
