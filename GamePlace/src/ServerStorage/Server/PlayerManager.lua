local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))

local PlayerManager = Knit.CreateService({
	Name = "PlayerManager",
	Client = {},
})

local Players = require(script.Parent.Players)

function PlayerManager:GetPlayerData(plr: Player)
	local m = Players:GetPlayerManager(plr)
	local slot = m:GetCurrentSlot()
	return slot.Data
end

return PlayerManager
