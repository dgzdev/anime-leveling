local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")
local DebugService = Knit.GetService("DebugService")
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
	Ray.FilterDescendantsInstances =
		{ Character, Workspace.Enemies, Workspace.NPC, game.Workspace:FindFirstChild("Debug") }
	Ray.RespectCanCollide = false
	Ray.IgnoreWater = false

	local Distance = 45
	local Pos

	local RayResult =
		Workspace:Raycast((CFramePosition * CFrame.new(0, 0, 2.5)).Position, CFramePosition.LookVector * Distance, Ray)

	if DebugService.Activated then
		DebugService:CreatePathBetweenTwoPoints(
			CFramePosition * CFrame.new(0, 0, 2.5),
			CFramePosition * CFrame.new(0, 0, -Distance),
			RayResult
		)
	end
	if RayResult then
		Distance = math.floor((CFramePosition.Position - RayResult.Position).Magnitude) ---distancia q ele deve teleportar
		Pos = RayResult.Position
	end

	RenderService:RenderForPlayersInArea(CFramePosition.Position, 200, {
		module = "Lightning",
		effect = "LStrike",
		root = Character.PrimaryPart,
		position = CFramePosition,
	})

	if Distance > 6.5 then
		if Pos then
			Character:PivotTo(CFrame.new(Pos))
		else
			Character:PivotTo(CFramePosition * CFrame.new(0, 0, -Distance))
		end
	end

	local Size = Vector3.new(5, 5, Distance)
	HitboxService:CreateFixedHitbox(CFramePosition * CFrame.new(0, 0, -(Distance / 2)), Size, 2, function(hitted: Model)
		--> Encontrou um inimigo
		for i = 1, 3, 1 do
			task.wait(0.1)
			DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", 2, 0)
		end
	end)
end
