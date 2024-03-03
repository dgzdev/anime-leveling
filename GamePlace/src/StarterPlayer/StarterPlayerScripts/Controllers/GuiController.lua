local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService
local ProgressionService

local GuiController = Knit.CreateController({
	Name = "GuiController",
})

function GuiController:BindPlayerHud()
	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("PlayerHud")
	local frame = teste:WaitForChild("Background")

	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	local PlayerData = PlayerService:GetData(Players.LocalPlayer)

	local PlayerStatus = frame:WaitForChild("PlayerStatus")

	local healthPR: ImageLabel = PlayerStatus:FindFirstChild("healthPR", true)
	local manaPR = PlayerStatus:FindFirstChild("manaPR", true)
	local expPR = PlayerStatus:FindFirstChild("expPR", true)

	local Gradient: UIGradient = healthPR:WaitForChild("UIGradient")
	local expGradient: UIGradient = expPR:WaitForChild("UIGradient")
	local manaGradient: UIGradient = manaPR:WaitForChild("UIGradient")

	local healthValue: TextLabel = healthPR:FindFirstChild("healthValue", true)

	local levelValue: TextLabel = PlayerStatus:FindFirstChild("levelValue", true)
	local manaValue: TextLabel = PlayerStatus:FindFirstChild("manaValue", true)
	local expValue: TextLabel = PlayerStatus:FindFirstChild("expValue", true)

	local function transformInString(number: number): string
		return tostring(math.floor(number))
	end

	local PlayerLevel = PlayerData.Level
	local PlayerMana = PlayerData.Mana
	local PlayerExperience = PlayerData.Experience
	local PlayerExperienceNeed = ProgressionService:ExpToNextLevel(Players.LocalPlayer)

	local percentage = math.floor(tonumber(PlayerExperience / PlayerExperienceNeed) * 100)

	levelValue.Text = transformInString(PlayerLevel)
	healthValue.Text = transformInString(Humanoid.Health)

	manaValue.Text = transformInString(PlayerMana)
	expValue.Text = transformInString(percentage) .. "%"

	expGradient.Offset = Vector2.new(percentage / 100, 0)

	local LevelUp = ProgressionService.LevelUp
	local ExpChanged = ProgressionService.ExpChanged

	LevelUp:Connect(function(level: number)
		PlayerLevel = level
		levelValue.Text = transformInString(PlayerLevel)
	end)
	ExpChanged:Connect(function(exp: number, max: number)
		PlayerExperience = exp
		PlayerExperienceNeed = max

		percentage = math.floor(tonumber(PlayerExperience / PlayerExperienceNeed) * 100)

		expValue.Text = transformInString(percentage) .. "%"
		TweenService:Create(expGradient, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), {
			Offset = Vector2.new(percentage / 100, 0),
		}):Play()
	end)

	local function BindHumanoid()
		Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")

		local function Update()
			healthValue.Text = transformInString(Humanoid.Health)

			local health, maxHealth = Humanoid.Health, Humanoid.MaxHealth
			local healthPercent = health / maxHealth

			local colorA = Color3.fromRGB(180, 119, 255)
			local colorB = Color3.fromRGB(255, 0, 0)

			local lerpColor = colorB:Lerp(colorA, healthPercent)

			TweenService:Create(Gradient, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), {
				Offset = Vector2.new(healthPercent, 0),
			}):Play()
			TweenService:Create(healthPR, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), {
				ImageColor3 = lerpColor,
			}):Play()
		end

		Humanoid.HealthChanged:Connect(function()
			Update()
		end)
		Update()
	end

	BindHumanoid()
	Players.LocalPlayer.CharacterAdded:Connect(BindHumanoid)
end

function GuiController:BindQuestEvents() end

function GuiController:KnitStart()
	local camera = Workspace.CurrentCamera

	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("PlayerHud")
	local frame = teste:WaitForChild("Background")

	PlayerService = Knit.GetService("PlayerService")
	ProgressionService = Knit.GetService("ProgressionService")

	self:BindPlayerHud()

	local amt = -0.005
	local defaultFov = 70
	local fovScale = 70

	local lastCF = camera.CFrame
	task.spawn(function()
		while true do
			task.wait()
			local dif = (lastCF.Position - camera.CFrame.Position) * amt
			local max = 0.1

			frame.Position = UDim2.fromScale(0.5 - math.clamp(dif.X + dif.Z, 0, max), 0.5 - math.clamp(dif.Y, 0, max))

			local fov = camera.FieldOfView
			local dif2 = ((defaultFov - fov) / fovScale) / 4
			frame.Size = UDim2.fromScale(1 + dif2, 1 + dif2)

			lastCF = camera.CFrame
		end
	end)
end

return GuiController
