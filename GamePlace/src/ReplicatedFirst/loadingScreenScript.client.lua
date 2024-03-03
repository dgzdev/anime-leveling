local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = ReplicatedFirst:WaitForChild("loadingScreen"):Clone()

local sound = ReplicatedFirst:WaitForChild("desolate")
sound:Play()

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

local function FadeOut()
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

	while true do
		local n = getpercentage()
		TweenService:Create(Value, TweenInfo.new(0.45, Enum.EasingStyle.Cubic), {
			Size = UDim2.fromScale(n, 1),
		}):Play()
		task.wait(0.25)
		Assets.Text = tostring(math.floor(n * 100)) .. "%"
	end
end)

local skipButton = Instance.new("TextButton", screenGui)
skipButton.Size = UDim2.fromScale(0.15, 0.2)
skipButton.AnchorPoint = Vector2.new(0, 0)
skipButton.Position = UDim2.fromScale(0.15, 0.8)
skipButton.BackgroundTransparency = 1
skipButton.Font = Enum.Font.GothamMedium

skipButton.TextColor3 = Color3.new(1, 1, 1)

skipButton.Text = "Skip"
skipButton.TextSize = 24
skipButton.Visible = false

screenGui.Parent = playerGui
-- Remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local start = tick()

if not game:IsLoaded() then
	game.Loaded:Wait()
end

task.delay(20, function()
	skipButton.Visible = true
end)

skipButton.Activated:Connect(function(inputObject, clickCount)
	print("[Loading] Skipped loading screen. (Took " .. math.floor(tick() - start) .. " seconds.)")
	FadeOut()
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

local endTick = tick()

print("[Loading] Loaded in " .. math.floor(endTick - start) .. " seconds.")
FadeOut()
