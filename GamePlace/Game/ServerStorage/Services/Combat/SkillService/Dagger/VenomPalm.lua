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
	local CFramePosition = p.Position
	local WeaponFolder = Character:FindFirstChild("Weapons")

	RenderService:RenderForPlayersInRadius({
	module = "Universal",
	effect = "VenomPalm",
	root = Character.PrimaryPart,
	position = CFramePosition,
}, CFramePosition.Position, 200)

	task.spawn(function() -- Para tirar o delay da skill.
		for i, weapon: Model in (WeaponFolder:GetChildren()) do --> Hitbox
			HitboxService:CreateFixedHitbox(CFramePosition, Vector3.new(5, 5, 5), 1, function(hitted: Model)
				task.spawn(function()
					DaggerHitFunction(Character, hitted, 2, "DaggerHit", "DaggerHit", 2.5, 1)
				end)
			end)
		end
	end)

	--> Teleporta o jogador para trás
	local Ray = RaycastParams.new()
	Ray.FilterType = Enum.RaycastFilterType.Exclude
	Ray.FilterDescendantsInstances = { Character, Workspace.Enemies, Workspace.NPC }

	local Distance = 25

	local RayResult = Workspace:Raycast(CFramePosition.Position, CFramePosition.LookVector * Distance, Ray)
	if RayResult then
		Distance = (CFramePosition.Position - RayResult.Position).Magnitude ---distancia q ele deve teleportar
	end

	Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, Distance))
end
