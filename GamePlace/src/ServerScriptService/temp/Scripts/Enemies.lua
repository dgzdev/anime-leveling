local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EnemiesManager = {}

local EasyEnemies = require(ReplicatedStorage.Modules.EasyEnemies)
local GameData = require(ServerStorage.GameData)

local Enemy = {}
Enemy.__index = Enemy
function Enemy.new(enemy: Model)
	local self = setmetatable({
		me = enemy,
		humanoid = enemy:WaitForChild("Humanoid") :: Humanoid,

		damage = 1,
		inteligence = 5,

		root = enemy:WaitForChild("HumanoidRootPart"),
	}, Enemy)

	local enemyData = GameData.gameEnemies[enemy.Name]
	if enemyData then
		if enemyData.HumanoidDescription then
			self.humanoid:ApplyDescription(enemyData.HumanoidDescription)
		end

		self.humanoid.Health = enemyData.Health
		self.humanoid.MaxHealth = enemyData.Health
		self.damage = enemyData.Damage
		self.inteligence = enemyData.Inteligence
	end

	EasyEnemies.new(enemy, {
		health = self.humanoid.MaxHealth, -- Enemy Health
		damage = self.damage, -- Enemy Base Damage
		wander = false, -- Enemy Wandering

		attack_range = self.inteligence * 5, -- Enemy Search Radius
		attack_radius = 5, -- Enemy Attack Radius

		attack_ally = false, -- Enemy Attacking Team Members
		attack_npcs = false, -- Enemy Attacking Random NPC's
		attack_players = true, -- Enemy Attacking Players

		default_animations = { 11555709524, 11555713135, 11555867639 }, -- Enemy Animations should be used for 'Light' Attacks // Example default_animations = {8972576500}
		default_functions = { -- Functions for said 'Light' Attacks ^
			function(target) -- functions pass the target as the first argument automatically
				print(target)
			end,
		},

		special_animations = { 11556032081 }, -- Enemy Animations should be used for 'Heavy' Attacks // Example special_animations = {8972576500}
		special_functions = { -- Functions for said 'Heavy' Attacks ^
			function(target) -- functions pass the target as the first argument automatically
				print("specialMove")
			end,
		},
	})

	return self
end

function EnemiesManager:Init()
	local Enemies = CollectionService:GetTagged("Enemies")
	for _, enemy: Model in ipairs(Enemies) do
		Enemy.new(enemy)
	end
end

return EnemiesManager
