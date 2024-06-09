local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ToolsFolder: Folder = game.ReplicatedStorage.Models.Tools

local HotbarService = Knit.CreateService({
	Name = "HotbarService",
	Client = {},
})

local PlayerService
local EquipService
local WeaponService

local Events = {
	Activate = function(Player: Player, data)
		local Tool = HotbarService:GetEquippedTool(Player.Character)
		if not Tool then
			return
		end

		local Classes = {
			Weapon = function()
				WeaponService:WeaponInput(Player.Character, "Attack", data)
			end,
		}
		local Class = Tool:GetAttribute("Class")
		if Classes[Class] then
			Classes[Class]()
		end
	end,
}

function HotbarService:GetEquippedTool(Character: Model)
	return Character:FindFirstChildWhichIsA("Tool")
end

function HotbarService:OnFireServer(player: Player, event: string, data: { any })
	if Events[event] then
		return Events[event](player, data)
	end
end

function HotbarService.Client:OnFireServer(...)
	return self.Server:OnFireServer(...)
end

function HotbarService:RenderItems(Player: Player)
	local PlayerData = PlayerService:GetData(Player)

	for _, v in PlayerData.Inventory do
		if not ToolsFolder:FindFirstChild(v.Name) then
			continue
		end
		local ToolClone = ToolsFolder[v.Name]:Clone() :: Tool
		ToolClone.RequiresHandle = false
		ToolClone.Enabled = true
		ToolClone.Parent = Player.Backpack

		ToolClone:SetAttribute("Id", v.Id)
		ToolClone:SetAttribute("Damage", v.Damage)
		ToolClone:SetAttribute("SwingSpeed", v.SwingSpeed)
		ToolClone:SetAttribute("Name", v.Name)
		ToolClone:SetAttribute("Class", v.Class)
		ToolClone:SetAttribute("Type", v.Type)
		ToolClone:SetAttribute("HitEffect", v.HitEffect)
		ToolClone:SetAttribute("DisplayName", v.DisplayName)
		ToolClone:SetAttribute("Grip", ToolClone.Grip)

		-- if PlayerData.Equiped.Id == v.Id then
		-- 	ToolClone.Name = "Weapon"
		-- 	ToolClone:SetAttribute("Equiped", true)
		-- end

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
	WeaponService = Knit.GetService("WeaponService")
end

return HotbarService
