local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")
local Workspace = game:GetService("Workspace")

return function(
	Character: Model,
	InputState: Enum.UserInputState,
	p: {
		Position: CFrame,
		Combo: number,
		Combos: number,
	},
	DaggerHitFunction
)
	local CFramePosition = p.Position --> Posicao de onde ele clicou pra soltar o ataque

	local Distance = 25

	Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, -Distance))

	warn("Executed")
	local Size = Vector3.new(10, 10, Distance)
	HitboxService:CreateFixedHitbox(CFramePosition * CFrame.new(0, 0, -(Distance / 2)), Size, 2, function(hitted: Model)
		task.spawn(function()
			DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", 2.5, 0)
		end)
	end)
end
