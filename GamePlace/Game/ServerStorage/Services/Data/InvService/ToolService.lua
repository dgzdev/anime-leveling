local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {},
})

local Players = game:GetService("Players")

local PlayerService
local InventoryService

local ToolsFolder = game.ReplicatedStorage.Models.Tools

function ToolService:ToolInput(Character: Model, Action: string)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Tool = ToolService:GetEquippedTool(Player)
	assert(Tool, `Tool not found\n{debug.traceback()}`)
	assert(Player, `Player not found\n{debug.traceback()}`)

	local Item = InventoryService:GetItemById(Player, Tool)
	assert(Item, "Item not found")
end

function ToolService:GetEquippedTool(Player: Player): Tool
	local Character = Player.Character
	if not Character then
		return
	end

	return Character:FindFirstChildWhichIsA("Tool")
end

function ToolService:RemoveEquippedTool(Player: Player)
	local Tool = ToolService:GetEquippedTool(Player)

	if Tool then
		Tool:Destroy()
	end
end
function ToolService:ClearPlayerTools(Player: Player)
	Player.Backpack:ClearAllChildren()
	ToolService:RemoveEquippedTool(Player)
end

function ToolService:GetItemFromEquippedTool(Player: Player)
	local Tool = ToolService:GetEquippedTool(Player)

	if not Tool then
		return
	end

	local ToolId = Tool:GetAttribute("Id")
	return InventoryService:GetItemById(ToolId)
end

function ToolService:LoadPlayerTools(Player: Player)
	local PlayerData = PlayerService:GetData(Player)

	ToolService:ClearPlayerTools(Player)

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

function ToolService.KnitStart()
	InventoryService = Knit.GetService("InvService")
end

return ToolService
