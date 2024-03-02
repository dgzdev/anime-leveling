local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Melee = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Default

local HitboxService

Melee.Default = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		HitboxService:CreateBlockHitbox(Character, p.Position * CFrame.new(0, 0, -2), Vector3.new(5, 5, 5), {
			dmg = 10,
			kb = 5,
			op = op,
			replicate = {
				["module"] = "Universal",
				["effect"] = "Replicate",
				["VFX"] = "CombatHit",
				["SFX"] = "Melee",
			},
		})
	end,

	Defense = function(...)
		Default.Defense(...)
	end,
}

-- item melee
Melee.Melee = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Melee.Default.Attack(Character, InputState, p)
	end,

	Defense = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Melee.Default.Defense(Character, InputState, p)
	end,
}

function Melee.Start(default)
	default = default
	HitboxService = Knit.GetService("HitboxService")
end

return Melee
