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

	local Ray = RaycastParams.new()
	Ray.FilterType = Enum.RaycastFilterType.Exclude
	Ray.FilterDescendantsInstances = { Character, Workspace.Enemies, Workspace.NPC }

	local Distance = 45

	local RayResult = Workspace:Raycast(CFramePosition.Position, CFramePosition.LookVector * Distance, Ray)
	if RayResult then
		Distance = (CFramePosition.Position - RayResult.Position).Magnitude ---distancia q ele deve teleportar
	end

	RenderService:RenderForPlayersInArea(CFramePosition.Position, 200, {
		module = "Lightning",
		effect = "LStrike",
		root = Character.PrimaryPart,
		position = CFramePosition,
	})

	Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, -Distance))

	local Size = Vector3.new(5, 5, Distance)
	HitboxService:CreateFixedHitbox(
		CFramePosition * CFrame.new(0, 0, -(Distance / 2)),
		Size,
		10,
		function(hitted: Model)
			--> Encontrou um inimigo
			for i = 1, 5, 1 do
				task.wait(0.1)
				DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", 2, 0)
			end
		end
	)
end
