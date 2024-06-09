local Knit = require(game.ReplicatedStorage.Packages.Knit)

local GrabService = Knit.CreateService({
	Name = "GrabService",
	Client = {
		Ungrab = Knit.CreateSignal(),
	},
})

function GrabService.Client:Ungrab(player: Player)
	player.Character.PrimaryPart.Anchored = false
end
function GrabService.Client:Grab(player: Player, position: CFrame)
	player.Character.PrimaryPart.Anchored = true
	player.Character:PivotTo(position)
end

return GrabService
