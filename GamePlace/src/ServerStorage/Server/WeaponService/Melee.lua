local Melee = {}

local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)

local Default

local HitboxService

Melee.Default = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		HitboxService:CreateBlockHitbox(p.Position * CFrame.new(0, 0, -2), Vector3.new(5, 5, 5), 10, 5, nil)
	end,

	Defense = function(...)
		Default.Defense(...)
	end,
}

-- item melee
Melee.Melee = {
	Attack = function(...)
		Melee.Default.Attack(...)
	end,

	Defense = function(...)
		Melee.Default.Defense(...)
	end,
}

function Melee.Start(default)
	print("Melee Start")
	default = default
	HitboxService = Knit.GetService("HitboxService")
end

return Melee
