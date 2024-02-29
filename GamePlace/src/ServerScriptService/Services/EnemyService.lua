local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EnemyService = Knit.CreateService({
	Name = "EnemyService",
})

--[[
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
]]

function EnemyService:KnitStart() end

return EnemyService
