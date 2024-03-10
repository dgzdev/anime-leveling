local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")

return function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame }, SwordHitFunction)
	local Size = Vector3.new(7, 7, 60)

	local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if not Root then
		return
	end

	local WeaponFolder = Character:FindFirstChild("Weapons")
	local alreadyHitted = false
	for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
		HitboxService:CreateHitbox(Character, Size, 16, function(hitted: Model | BasePart)
			if alreadyHitted then
				return "break"
			end

			alreadyHitted = true
			SwordHitFunction(Character, hitted, 30, "LightningSwordHit", "SwordHit", 2, 2)

			if hitted:IsA("Accessory") then
				hitted = hitted.Parent
			end

			RenderService:RenderForPlayersInArea(Root.CFrame.Position, 200, {
				module = "Lightning",
				effect = "Lightning",
				root = hitted.PrimaryPart or hitted,
			})

			return "break"
		end)
	end
end
