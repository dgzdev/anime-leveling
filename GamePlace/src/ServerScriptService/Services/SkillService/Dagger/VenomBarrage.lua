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

	--> Teleporta o jogador para FRENTE
	local Ray = RaycastParams.new()
	Ray.FilterType = Enum.RaycastFilterType.Exclude
	Ray.FilterDescendantsInstances = { Character, Workspace.Enemies, Workspace.NPC }

	local Distance = 15

	local RayResult = Workspace:Raycast(CFramePosition.Position, CFramePosition.LookVector * Distance, Ray)
	if RayResult then
		Distance = (CFramePosition.Position - RayResult.Position).Magnitude ---distancia q ele deve teleportar
	end

	warn("Executed")
	Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, -Distance)) --> -Distance = frente.
end
