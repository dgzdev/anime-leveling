local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ZonePlus = require(game.ReplicatedStorage.Modules.Zone)

local MapLimitsService = Knit.CreateService({
	Name = "MapLimitsService",
	Client = {},
})

function MapLimitsService.OnPlayerLeft(player: Player) end

function MapLimitsService:KnitInit()
	local Spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if not Spawn then
		warn("No spawn found, creating one")
		Spawn = Instance.new("SpawnLocation", Workspace)
	end

	local Zone = ZonePlus.fromRegion(Spawn.CFrame, Vector3.new(2048, 256, 2048))
	Zone.playerExited:Connect(function(player: Player)
		local character = player.Character or player.CharacterAdded:Wait()
		warn("Player " .. player.Name .. " exited the map")

		character:PivotTo(Spawn.CFrame * CFrame.new(0, 2, 0))
	end)
end

return MapLimitsService
