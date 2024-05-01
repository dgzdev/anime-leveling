local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ToolsFolder = game.ReplicatedStorage.Models.Tools

local HotbarService = Knit.CreateService({
	Name = "HotbarService",
	Client = {},
})

local PlayerService

HotbarService.Events = {
	["Equip"] = function(player: Player) end,
	["Unequip"] = function(player: Player) end,
	["Activate"] = function(player: Player) end,
}

function HotbarService:OnFireServer(player: Player, event: string, ...)
	if HotbarService.Events[event] then
		HotbarService.Events[event](player, ...)
	end
end

function HotbarService:RenderItems(Player: Player)
	local PlayerData = PlayerService:GetData(Player)
	for i, v in pairs(PlayerData.Inventory) do
		if not ToolsFolder[i] then
			continue
		end
		local ToolClone = ToolsFolder[i]:Clone() :: Tool
		ToolClone.RequiresHandle = false
		ToolClone.Enabled = true
		ToolClone.Parent = Player.Backpack

		if table.find(PlayerData.Hotbar, v.Id) then
			local index = table.find(PlayerData.Hotbar, v.Id)
			ToolClone:SetAttribute("Hotbar", index)
		end
	end
end
function HotbarService.Client:RenderItems(...)
	return self.Server:RenderItems(...)
end

function HotbarService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return HotbarService
