local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local EasyEnemies = require(ReplicatedStorage.Modules.EasyEnemies)

local GameData = require(ServerStorage.GameData)

local WeaponService

local HealthHud: BillboardGui = ReplicatedStorage.Models.HealthHud

local EnemyService = Knit.CreateService({
	Name = "EnemyService",
})

EnemyService.Enemies = {}

function EnemyService:UpdateHealthHud(humanoid: Humanoid, healthHud: BillboardGui)
	local Background = healthHud:FindFirstChild("Background")

	local PrimaryHP: Frame = Background:FindFirstChild("PrimaryHP")
	local HPInfo: TextLabel = Background:FindFirstChild("HPInfo")
	local EnemyName: TextLabel = healthHud:FindFirstChild("EnemyName")

	HPInfo.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)

	TweenService:Create(PrimaryHP, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		Size = UDim2.fromScale(humanoid.Health / humanoid.MaxHealth, 1)
	}):Play()

	TweenService:Create(PrimaryHP, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
		BackgroundColor3 = PrimaryHP.BackgroundColor3:Lerp(Color3.fromRGB(255,0,0), 1-(humanoid.Health / humanoid.MaxHealth))
	}):Play()

	EnemyName.Text = humanoid.Parent.Name

	healthHud.Enabled = (humanoid.Health > 0)
end

function EnemyService:CreateEnemy(
	model: Model,
	props: {
		damage: number,
		inteligence: number,
	}?
)
	local Data = ReplicatedStorage.Models.Utils.EnemyData:Clone()
	Data.Parent = model
	Data.Name = "Data"

	local EnemyData = require(Data)

	--[[
	if GameData.gameEnemies[model.Name] then
		-- trocar dano, etc
	end

	]]

	local Damage = EnemyData.Info.Damage

	local RespawnTime = 10
	local Inteligence = props.inteligence or 5
	local Humanoid = model:FindFirstChildWhichIsA("Humanoid")

	Humanoid.MaxHealth = EnemyData.Info.Health
	Humanoid.Health = EnemyData.Info.Health

	local Root = Humanoid.RootPart
	local Animator: Animator = Humanoid:WaitForChild("Animator")

	local healthHud = HealthHud:Clone()
	healthHud.Parent = model
	healthHud.Adornee = model:FindFirstChild("Head")


	Humanoid.Died:Connect(function()
		for _, Animation: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
			Animation:Stop(0)
		end

		task.wait(2)
		model.Parent = ServerStorage:WaitForChild("Storage")
		task.wait(RespawnTime)

		model.Parent = Workspace.Enemies
		Humanoid.Health = Humanoid.MaxHealth

		self:UpdateHealthHud(Humanoid, healthHud)
	end)

	self:UpdateHealthHud(Humanoid, healthHud)
	Humanoid.HealthChanged:Connect(function(health)
		self:UpdateHealthHud(Humanoid, healthHud)
	end)

	for _, bp: BasePart in ipairs(model:GetDescendants()) do
		if bp:IsA("BasePart") then
			bp.CollisionGroup = "Enemies"
		end
	end

	if GameData.gameEnemies[model.Name] then
		local enemyData = GameData.gameEnemies[model.Name]

		if enemyData.HumanoidDescription then
			Humanoid:ApplyDescription(enemyData.HumanoidDescription)
		end

		Damage = enemyData.Damage
		Inteligence = enemyData.Inteligence
	end

	model:SetAttribute("Enemy", true)

	local function createLightAttack(target: Model)
		local hum = target:FindFirstChildWhichIsA("Humanoid")
		if not hum then
			return
		end

		WeaponService:WeaponInput(model, "Attack", Enum.UserInputState.End, {
			Position = Root.CFrame,
			Combo = 1,
			Combos = 3,
		})
	end

	return EasyEnemies.new(model, {
		health = Humanoid, -- Enemy Health
		damage = Damage, -- Enemy Base Damage
		wander = false, -- Enemy Wandering

		attack_range = Inteligence * 5, -- Enemy Search Radius
		attack_radius = 7, -- Enemy Attack Radius

		attack_ally = false, -- Enemy Attacking Team Members
		attack_npcs = false, -- Enemy Attacking Random NPC's
		attack_players = true, -- Enemy Attacking Players

		default_animations = { 16529107075, 16529111104, 16529114070 }, -- Enemy Animations should be used for 'Light' Attacks // Example default_animations = {8972576500}
		default_functions = { -- Functions for said 'Light' Attacks ^
			createLightAttack,
			createLightAttack,
			createLightAttack,
		},

		special_animations = { 16529117516 }, -- Enemy Animations should be used for 'Heavy' Attacks // Example special_animations = {8972576500}
		special_functions = { -- Functions for said 'Heavy' Attacks ^
			function(target) -- functions pass the target as the first argument automatically
				local hum = target:FindFirstChildWhichIsA("Humanoid")
				if not hum then
					return
				end

				WeaponService:WeaponInput(model, "Attack", Enum.UserInputState.End, {
					Position = Root.CFrame,
					Combo = 3,
					Combos = 3,
				})
			end,
		},
	})
end

function EnemyService.ChildAdded(child: Instance)
	if child:IsA("Model") then
		if not EnemyService.Enemies[child] then
			if child:FindFirstChild("Data") then
				return
			end
			EnemyService.Enemies[child] = EnemyService:CreateEnemy(child, {})
		end
	end
end

function EnemyService.ChildRemoving(child: Instance)
	if child:IsA("Model") then
		EnemyService.Enemies[child] = nil
	end
end

function EnemyService.KnitStart()
	WeaponService = Knit.GetService("WeaponService")

	local Folder: Folder = Workspace.Enemies

	local Enemies = Folder:GetChildren()
	for _, Enemy in ipairs(Enemies) do
		if not EnemyService.Enemies[Enemy] then
			EnemyService.ChildAdded(Enemy)
		end
	end

	Folder.ChildAdded:Connect(EnemyService.ChildAdded)
	Folder.ChildRemoved:Connect(EnemyService.ChildRemoving)
end

return EnemyService
