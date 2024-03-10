local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")

return function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame }, SwordHitFunction)
	local Mid = Data.Position * CFrame.new(0, 0, -30)

	RenderService:RenderForPlayersInArea(Mid.Position, 200, {
		module = "Universal",
		effect = "FlashStrike",
		root = Character.PrimaryPart,
	})

	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { workspace:WaitForChild("Enemies") }

	local WeaponFolder = Character:FindFirstChild("Weapons")
	for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
		HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
			SwordHitFunction(Character, hitted, 5, "SwordHit", "SwordHit", nil, 0)
		end, op)
	end
end
