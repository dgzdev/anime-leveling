local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")

return function(
	Character: Model,
	InputState: Enum.UserInputState,
	p: {
		Position: CFrame,
	},

	MeleeHitFunction
)
	RenderService:RenderForPlayersInRadius({
		["module"] = "Melee",
		["effect"] = "StrongPunch",
		root = Character.PrimaryPart,
	}, p.Position.Position, 100)

	local op = WeaponService:GetOverlapParams(Character)

	task.spawn(function()
		HitboxService:CreateHitbox(Character, Vector3.new(6, 5, 10), 2, function(hitted)
			MeleeHitFunction(Character, hitted, 15, "CombatHit", "Melee", nil, 3)
		end, op)
	end)
end
