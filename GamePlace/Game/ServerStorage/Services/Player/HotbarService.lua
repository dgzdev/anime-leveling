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
	Equip = function(Player: Player)
		EquipService:EquipItem(Player)
	end,
	Unequip = function(Player: Player)
		EquipService:UnequipItem(Player)
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

	for _, item in PlayerData.Inventory do
		if item.Class == "Skill" then
			local ToolSkill = Instance.new("Tool")
			ToolSkill.Name = item.Name
			ToolSkill:SetAttribute("DisplayName", item.DisplayName)
			ToolSkill:SetAttribute("Id", item.Id)
			ToolSkill:SetAttribute("Class", "Skill")
			ToolSkill:SetAttribute("Type", item.Type)

			if table.find(PlayerData.Hotbar, item.Id) then
				local index = table.find(PlayerData.Hotbar, item.Id)
				ToolSkill:SetAttribute("Hotbar", index)
			end

			ToolSkill.RequiresHandle = false
			ToolSkill.Enabled = true
			ToolSkill.Parent = Player.Backpack

			continue
		end

		if not ToolsFolder:FindFirstChild(item.Name) then
			continue
		end

		local ToolClone = ToolsFolder[item.Name]:Clone() :: Tool
		ToolClone:SetAttribute("Id", item.Id)
		ToolClone:SetAttribute("Damage", item.Damage)
		ToolClone:SetAttribute("SwingSpeed", item.SwingSpeed)
		ToolClone:SetAttribute("Name", item.Name)
		ToolClone:SetAttribute("Class", item.Class)
		ToolClone:SetAttribute("Type", item.Type)
		ToolClone:SetAttribute("HitEffect", item.HitEffect)
		ToolClone:SetAttribute("DisplayName", item.DisplayName)
		ToolClone:SetAttribute("Grip", ToolClone.Grip)

		if table.find(PlayerData.Hotbar, item.Id) then
			local index = table.find(PlayerData.Hotbar, item.Id)
			ToolClone:SetAttribute("Hotbar", index)
		end

		ToolClone.RequiresHandle = false
		ToolClone.Enabled = true
		ToolClone.Parent = Player.Backpack
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
