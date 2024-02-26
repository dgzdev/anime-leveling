local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)
local WeaponService

local Default = {
	[Enum.UserInputType.MouseButton1] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			print("mb1")

			WeaponService:WeaponInput("Attack", inputstate)
		end,
		name = "Attack",
	},
	[Enum.UserInputType.MouseButton2] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			print("mb2")

			WeaponService:WeaponInput("Defense", inputstate)
		end,
		name = "Defense",
	},
}

function Default.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return Default
