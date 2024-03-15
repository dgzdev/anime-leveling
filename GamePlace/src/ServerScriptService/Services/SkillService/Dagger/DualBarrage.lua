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

	for i = 1, 4, 1 do
		HitboxService:CreateHitbox(Character, Vector3.new(5, 5, 5), 10, function(hitted: Model)
			DaggerHitFunction(Character, hitted, 2, "DaggerHit", "DaggerHit", nil, 1) --> puxa dano
		end)
		task.wait(0.25)
	end
end
