local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EnemiesManager = {}

local EasyEnemies = require(ReplicatedStorage.Modules.EasyEnemies)
local GameData = require(ServerStorage.GameData)
local HitService = require(script.Parent.Parent.Parent.Server.CombatSystem.HitService)

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)
local CombatUtils = require(ReplicatedStorage.Modules.CombatUtils)

local Enemy = {}
Enemy.__index = Enemy
function Enemy.new(enemy: Model)
	local self = setmetatable({
		me = enemy,
		humanoid = enemy:WaitForChild("Humanoid") :: Humanoid,

		damage = 1,
		inteligence = 5,

		root = enemy:WaitForChild("HumanoidRootPart") :: BasePart,
	}, Enemy)

	local hud: BillboardGui = ReplicatedStorage.Models.UI.HealthHud:Clone()
	local enemyTextLabel: TextLabel = hud:WaitForChild("Enemy")
	local backgroundFrame: Frame = hud:WaitForChild("Health")
	local primaryFrame: Frame = backgroundFrame:WaitForChild("PrimaryHP")
	local healthInfo: TextLabel = backgroundFrame:WaitForChild("HPInfo")

	local enemyData = GameData.gameEnemies[enemy.Name]
	if enemyData then
		if enemyData.HumanoidDescription then
			self.humanoid:ApplyDescription(enemyData.HumanoidDescription)
		end

		self.humanoid.MaxHealth = enemyData.Health
		task.wait()
		self.humanoid.Health = enemyData.Health

		self.damage = enemyData.Damage
		self.inteligence = enemyData.Inteligence
	end

	self:UpdateUI({
		hud = hud,
		enemyTextLabel = enemyTextLabel,
		backgroundFrame = backgroundFrame,
		primaryFrame = primaryFrame,
		healthInfo = healthInfo,
	})

	local function createLightAttack(target: Model)
		return self.LightAttack(self, target)
	end

	EasyEnemies.new(enemy, {
		health = self.humanoid.MaxHealth, -- Enemy Health
		damage = self.damage, -- Enemy Base Damage
		wander = false, -- Enemy Wandering

		attack_range = self.inteligence * 5, -- Enemy Search Radius
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

				local kb = (self.root.CFrame.LookVector * HitService:getMass(target) * 10)
				HitService:Hit(self.humanoid, hum, self.damage * 2, false, kb)
			end,
		},
	})

	return self
end

type enemyType = typeof(Enemy)
function Enemy.UpdateUI(
	self: enemyType,
	gui: {
		hud: BillboardGui,
		enemyTextLabel: TextLabel,
		backgroundFrame: Frame,
		primaryFrame: Frame,
		healthInfo: TextLabel,
	}
)
	task.wait()

	self.hud = gui.hud
	self.enemyTextLabel = gui.enemyTextLabel
	self.backgroundFrame = gui.backgroundFrame
	self.primaryFrame = gui.primaryFrame
	self.healthInfo = gui.healthInfo

	local me: Model = self.me
	local head: BasePart = me:FindFirstChild("Head")
	if not head then
		head = me:WaitForChild("HumanoidRootPart")
	end
	local ySize = head.Size.Y

	self.hud.StudsOffset = Vector3.new(0, ySize + 1, 0)

	self.hud.Parent = self.me
	self.hud.Enabled = true
	self.hud.Adornee = head

	self.enemyTextLabel.Text = self.me.Name
	self.healthInfo.Text = self.humanoid.Health .. " / " .. self.humanoid.MaxHealth
	self.primaryFrame.Size = UDim2.fromScale(1, 1)

	self.humanoid.HealthChanged:Connect(function(h: number)
		if h > 0 then
			self.hud.Enabled = true
		else
			self.hud.Enabled = false
		end

		self.healthInfo.Text = self.humanoid.Health .. " / " .. self.humanoid.MaxHealth
		self.primaryFrame:TweenSize(UDim2.fromScale(self.humanoid.Health / self.humanoid.MaxHealth, 1))
	end)

	self.humanoid.Died:Connect(function()
		self.hud.Enabled = false
	end)
end

function Enemy.LightAttack(self, target: Model)
	local hum = target:FindFirstChildWhichIsA("Humanoid")
	if not hum then
		return
	end

	if self.me:GetAttribute("Stun") then
		return
	end

	local isDefending = target:GetAttribute("Defending")
	local defenseTick = target:GetAttribute("DefenseTick") or 0

	if isDefending then
		if (tick() - defenseTick) < 0.3 then
			VFX:ApplyParticle(target, "PerfectBlock")
			SFX:Apply(self.me, "Parry")

			VFX:ApplyParticle(self.me, "BlockBreak")

			CombatUtils:Stun(self.me, 4)
			return
		end

		local defenseHits = target:GetAttribute("DefenseHits") or 0
		target:SetAttribute("DefenseHits", defenseHits + 1)
		if defenseHits < 3 then
			VFX:ApplyParticle(target, "BlockedHit")
			SFX:Apply(target, "Block")
			return
		elseif defenseHits == 3 then
			SFX:Apply(target, "BlockBreak")
			VFX:ApplyParticle(target, "BlockBreak")
			target:SetAttribute("Stun", true)
		end
	end

	VFX:ApplyParticle(target, "CombatHit")
	SFX:Apply(target, "Melee")

	local kb = (self.root.CFrame.LookVector * HitService:getMass(target) * 5)
	HitService:Hit(self.humanoid, hum, self.damage, false, kb)
end

function EnemiesManager:Init()
	local Enemies = CollectionService:GetTagged("Enemies")
	for _, enemy: Model in ipairs(Enemies) do
		Enemy.new(enemy)
	end
end

return EnemiesManager
