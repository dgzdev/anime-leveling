local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService
local ProgressionService
local QuestService
local InventoryService

local GuiController = Knit.CreateController({
	Name = "GuiController",
})

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Menu_UI = PlayerGui:WaitForChild("Menu_UI")
local Points = Menu_UI:WaitForChild("Points")

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

			local colorA = Color3.fromRGB(255, 123, 125)
			local colorB = Color3.fromRGB(44, 21, 21)

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

function GuiController:BindHotbar()
	local InventoryUI = Menu_UI:WaitForChild("Inventory")
	local Background = InventoryUI:WaitForChild("Background")
	local InventoryFrame = Background:WaitForChild("Inventory")

	local Item = InventoryFrame:WaitForChild("Item")

	for i, v in (InventoryFrame:GetChildren()) do
		if v:IsA("TextButton") and v.Name ~= "Item" then
			v:Destroy()
		end
	end

	local PlayerInventory = InventoryService:GetPlayerInventory()
	local gameWeapons, rarity = InventoryService:GetGameWeapons()

	for itemName: string, item in PlayerInventory do
		local newItem = Item:Clone()
		newItem.Parent = InventoryFrame

		newItem:SetAttribute("ID", item.Id)
		newItem:SetAttribute("Name", itemName)

		local itemData = gameWeapons[itemName]

		if not itemData.Rarity then
			warn("Rarity not found for item", itemName)
		end

		local rarityColor = rarity[itemData.Rarity or "E"]
		newItem.BackgroundColor3 = rarityColor

		local RarityOrder = {
			["E"] = 1,
			["D"] = 2,
			["C"] = 3,
			["B"] = 4,
			["A"] = 5,
			["S"] = 6,
		}

		local Number = 10
		local Order = RarityOrder[itemData.Rarity or "E"]
		newItem.Name = tostring(Number - Order)

		local Model = game.ReplicatedStorage.Models:FindFirstChild(itemName, true)
		if not Model then
			warn("Model not found for item", itemName)
		end

		if Model then
			local Clone: Model = Model:Clone()

			if Clone:IsA("Folder") then
				local a = Clone:FindFirstChildWhichIsA("Model", true)
				if a then
					Clone = a:Clone()
				end
				local b = Clone:FindFirstChildWhichIsA("ImageLabel", true)
				if b then
					b.Parent = newItem
				end
			end
			if Clone:IsA("ImageLabel") then
				Clone.Parent = newItem
			end
			if Clone:IsA("Model") then
				local WorldModel = newItem:FindFirstChild("WorldModel", true)
				Clone.Parent = WorldModel

				local ViewFrame: ViewportFrame = newItem:FindFirstChild("ViewportFrame", true)

				local Camera = Instance.new("Camera")
				Camera.Parent = ViewFrame
				ViewFrame.CurrentCamera = Camera

				local Size = Clone:GetExtentsSize().Magnitude

				Camera.FieldOfView = 80
				Camera.CameraSubject = Clone
				Camera.CameraType = Enum.CameraType.Scriptable

				Clone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0))

				Camera.CFrame = CFrame.new(Clone:GetBoundingBox().Position + Vector3.new(0, 0, 2 + (Size / 4)))
				Camera.Focus = Camera.CFrame
			end
		end

		newItem.Visible = true
	end
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

function GuiController:AlertGui(message: string)
	local PlayerHud = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PlayerHud")
	local AlertGui = PlayerHud:WaitForChild("Background"):WaitForChild("AlertGui")

	TweenService:Create(
		AlertGui,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Position = UDim2.fromScale(0.5, 0.03) }
	):Play()

	AlertGui.Information.Text = message

	task.delay(5, function()
		TweenService:Create(
			AlertGui,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(0.5, -1) }
		):Play()
	end)
end

function GuiController:BindQuestEvents()
	local PlayerHud = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PlayerHud")
	local QuestGui = PlayerHud:WaitForChild("Background"):WaitForChild("QuestGui")

	local Title = QuestGui:WaitForChild("Title")
	local Example = QuestGui:WaitForChild("Example")

	local playerQuests = {}

	QuestService.OnQuestEnd:Connect(function(questName: string)
		local new = QuestGui:FindFirstChild(questName)
		if new then
			local questData = playerQuests[questName]
			local message = "Quest completed! "
			local rewards = questData.Rewards

			if rewards then
				message = message .. "Received "
				if rewards.Experience then
					message = message .. `<font color="#FFB641">{rewards.Experience} Experience </font>`
				end
			end

			GuiController:AlertGui(message)
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

		playerQuests[questName] = questData
	end)
	QuestService.OnQuestUpdate:Connect(function(questName: string, questData)
		local questString = self:ConvertQuestData(questData)
		local new = QuestGui:FindFirstChild(questName)
		if new then
			new.Label.Text = questString
		end
	end)
end

function GuiController:RenderPoints(points: {
	Attack: number,
	Endurance: number,
	Agility: number,
	Inteligence: number,
}?)
	local Background = Points:WaitForChild("Background")
	local PointsGui = Background:WaitForChild("Points")
	local PointsValue: TextLabel = Background:WaitForChild("PointsValue")
	local PlayerPoints = points or ProgressionService:GetPointsDistribuition(Players.LocalPlayer)

	for pointName: string, value: number in PlayerPoints do
		local point = PointsGui:FindFirstChild(pointName)
		if point then
			local PointsText = point:FindFirstChild("Points", true)
			local Size = point:FindFirstChild("Size", true)

			PointsText.Text = tostring(value)
			local percentage = value / 100

			TweenService:Create(Size, TweenInfo.new(1.2), {
				Size = UDim2.fromScale(1, percentage),
			}):Play()
		end
	end

	local Text = "%u POINTS"
	local PTS = ProgressionService:GetPointsAvailable(Players.LocalPlayer) or 0
	PointsValue.Text = Text:format(PTS)
end

function GuiController:KnitInit()
	PlayerService = Knit.GetService("PlayerService")
	ProgressionService = Knit.GetService("ProgressionService")
	QuestService = Knit.GetService("QuestService")
	InventoryService = Knit.GetService("InventoryService")
end

function GuiController:KnitStart()
	coroutine.wrap(function()
		local camera = Workspace.CurrentCamera

		local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local teste = plrGui:WaitForChild("PlayerHud")
		local frame = teste:WaitForChild("Background")

		self:BindPlayerHud()
		self:BindQuestEvents()
		self:RenderPoints()
		self:BindHotbar()

		ProgressionService.NewPoint:Connect(function()
			self:RenderPoints()
		end)
		ProgressionService.PointWasted:Connect(function()
			self:RenderPoints()
		end)

		local amt = -0.005
		local defaultFov = 70
		local fovScale = 70

		local lastCF = camera.CFrame
		task.spawn(function()
			while true do
				task.wait()
				local dif = (lastCF.Position - camera.CFrame.Position) * amt
				local max = 0.1

				frame.Position =
					UDim2.fromScale(0.5 - math.clamp(dif.X + dif.Z, 0, max), 0.5 - math.clamp(dif.Y, 0, max))

				local fov = camera.FieldOfView
				local dif2 = ((defaultFov - fov) / fovScale) / 4
				frame.Size = UDim2.fromScale(1 + dif2, 1 + dif2)

				lastCF = camera.CFrame
			end
		end)
	end)()
end

return GuiController
