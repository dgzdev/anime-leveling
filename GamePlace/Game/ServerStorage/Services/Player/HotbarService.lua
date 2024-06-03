local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ToolsFolder: Folder = game.ReplicatedStorage.Models.Tools

local HotbarService = Knit.CreateService({
	Name = "HotbarService",
	Client = {},
})

local PlayerService
local EquipService

function HotbarService:OnFireServer(player: Player, event: string, ...)
	if HotbarService.Events[event] then
		return HotbarService.Events[event](player, ...)
	end
end

function HotbarService.Client:OnFireServer(...)
	return self.Server:OnFireServer(...)
end

function HotbarService:RenderItems(Player: Player)
	local PlayerData = PlayerService:GetData(Player)
	for i, v in pairs(PlayerData.Inventory) do
		if not ToolsFolder:FindFirstChild(i) then
			continue
		end
		local ToolClone = ToolsFolder[i]:Clone() :: Tool
		ToolClone.RequiresHandle = false
		ToolClone.Enabled = true
		ToolClone.Parent = Player.Backpack

		ToolClone:SetAttribute("Id", v.Id)
		ToolClone:SetAttribute("Name", i)
		ToolClone:SetAttribute("Type", "Weapon")
		ToolClone:SetAttribute("Grip", ToolClone.Grip)

		if PlayerData.Equiped.Id == v.Id then
			ToolClone.Name = "Weapon"
			ToolClone:SetAttribute("Equiped", true)
		end

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
	EquipService = Knit.GetService("EquipService")
end

return HotbarService
