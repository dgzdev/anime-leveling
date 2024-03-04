local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService
local ProgressionService
local QuestService

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

	local healthPR: ImageLabel = PlayerStatus:WaitForChild("healthBG"):WaitForChild("healthPR")
	local expPR: ImageLabel = PlayerStatus:WaitForChild("expBG"):WaitForChild("expPR")
	local manaPR: ImageLabel = PlayerStatus:WaitForChild("manaBG"):WaitForChild("manaPR")
	local levelBG: ImageLabel = PlayerStatus:WaitForChild("levelBG")

	local Gradient: UIGradient = healthPR:WaitForChild("UIGradient")
	local expGradient: UIGradient = expPR:WaitForChild("UIGradient")
	local manaGradient: UIGradient = manaPR:WaitForChild("UIGradient")

	local healthValue: TextLabel = healthPR:WaitForChild("healthValue")

	local levelValue: TextLabel = levelBG:WaitForChild("levelValue")
	local manaValue: TextLabel = manaPR:WaitForChild("manaValue")
	local expValue: TextLabel = expPR:WaitForChild("expValue")

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

function GuiController:ConvertQuestData(questData: {
	Amount: number,
	EnemyName: string,
	Rewards: {
		Experience: number,
	},
	Type: string,
}): string
	local amount = questData.Amount
	local enemyName = questData.EnemyName
	local rewards = questData.Rewards
	local questType = questData.Type

	local str = "%s %u %s"

	local Table = {
		["Type"] = {
			["Kill Enemies"] = "Defeat",
		},
		["EnemyName"] = {
			["Goblin"] = "%ss",
		},
	}

	local TypeString = Table.Type[questType]
	local EnemyString = (Table.EnemyName[enemyName]):format(enemyName)

	return str:format(TypeString, amount, EnemyString)
end

function GuiController:BindQuestEvents()
	local PlayerHud = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PlayerHud")
	local QuestGui = PlayerHud:WaitForChild("Background"):WaitForChild("QuestGui")

	local Title = QuestGui:WaitForChild("Title")
	local Example = QuestGui:WaitForChild("Example")

	QuestService.OnQuestEnd:Connect(function(questName: string)
		local new = QuestGui:FindFirstChild(questName)
		if new then
			new:Destroy()
		end
	end)
	QuestService.OnQuestReceive:Connect(function(questName: string, questData)
		local questString = self:ConvertQuestData(questData)
		local new = Example:Clone()
		new.Label.Text = questString
		new.Name = questName
		new.Parent = QuestGui
		new.Visible = true
	end)
	QuestService.OnQuestUpdate:Connect(function(questName: string, questData)
		local questString = self:ConvertQuestData(questData)
		local new = QuestGui:FindFirstChild(questName)
		if new then
			new.Label.Text = questString
		end
	end)
end

function GuiController:KnitStart()
	local camera = Workspace.CurrentCamera

	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("PlayerHud")
	local frame = teste:WaitForChild("Background")

	PlayerService = Knit.GetService("PlayerService")
	ProgressionService = Knit.GetService("ProgressionService")
	QuestService = Knit.GetService("QuestService")

	self:BindPlayerHud()
	self:BindQuestEvents()

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
