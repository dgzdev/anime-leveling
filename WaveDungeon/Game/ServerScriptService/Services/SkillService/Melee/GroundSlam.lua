local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")

return function(Character, InputState, p, MeleeHitFunction)
	local op = WeaponService:GetOverlapParams(Character)

	RenderService:RenderForPlayersInArea(p.Position.Position, 100, {
		["module"] = "Melee",
		["effect"] = "GroundSlam",
		root = Character.PrimaryPart,
	})

	HitboxService:CreateHitbox(Character, Vector3.new(25, 5, 25), 3, function(hitted)
		MeleeHitFunction(Character, hitted, 0, "CombatHit", "Melee", nil, 3)
	end, op)
end
