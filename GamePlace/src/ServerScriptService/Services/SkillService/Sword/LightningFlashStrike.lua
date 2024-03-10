local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")

return function(
	Character: Model,
	InputState: Enum.UserInputState,
	Data: { Position: CFrame, Camera: CFrame },
	SwordHitFunction
)
	local Mid = Data.Position * CFrame.new(0, 0, -30)

	local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if not Root then
		return
	end

	RenderService:RenderForPlayersInArea(Mid.Position, 200, {
		module = "Lightning",
		effect = "FlashStrike",
		root = Root,
	})

	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { workspace:WaitForChild("Enemies") }

	local WeaponFolder = Character:FindFirstChild("Weapons")
	for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
		HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
			SwordHitFunction(Character, hitted, 5, "LightningSwordHit", "SwordHit", nil, 0)
		end, op)
	end

	RenderService:RenderForPlayersInArea(Mid.Position, 200, {
		["module"] = "Universal",
		["effect"] = "Replicate",
		["VFX"] = "SlashHit",
		root = Character.PrimaryPart,
	})
end
