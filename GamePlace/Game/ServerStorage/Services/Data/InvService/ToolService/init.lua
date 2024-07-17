local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {},
})

local Players = game:GetService("Players")

local PlayerService
local InventoryService

local ToolsFolder = game.ReplicatedStorage.Models.Tools
local ToolsModules = {}

--[[
	Service responsavel por carregar as tools do player com base no inventário dele,
	receber os inputs eventos/inputs das tools (Equipped, Unequipped e Activated) e chamar 
	as funcoes de cada uma.
]]


--[[
	Recebe os eventos das tools, é possivel criar modulos para cada Classe de tool assim fazendo todas as tools que 
	tiverem aquela classe utilizarem ela como "Default" ou abstrair para um modulo especifico da tool, utilizando o nome da tool.
]]
function ToolService:ToolInput(Character: Model, Action: string, Data: {any})
	local Player = Players:GetPlayerFromCharacter(Character)
	local Tool = ToolService:GetEquippedTool(Player)
	assert(Tool, `Tool not found\n{debug.traceback()}`)
	assert(Player, `Player not found\n{debug.traceback()}`)

	local Item = InventoryService:GetItemById(Player, Tool)
	assert(Item, "Item not found")

	local SpecificToolModule = ToolsModules[Item.Name]
	local ClassToolModule = ToolsModules[Item.Class]

	local CalledSpecific = false
	if SpecificToolModule then
		if SpecificToolModule[Action] then
			SpecificToolModule[Action](Character, Item)
			CalledSpecific = true
		end
	end

	if not CalledSpecific then
		if ClassToolModule[Action] then
			ClassToolModule[Action](Character, Item)
		end
	end
end
function ToolService.Client:ToolInput(Player: Player, Action: string, Data: {any})
	self.Server:ToolInput(Player.Character, Action, Data)
end

--[[ Retorna a tool que esta atualmente no Character do player ]]
function ToolService:GetEquippedTool(Player: Player): Tool
	local Character = Player.Character
	if not Character then
		return
	end

	return Character:FindFirstChildWhichIsA("Tool")
end

--[[ Remove a tool que esta no Character do player ]]
function ToolService:RemoveEquippedTool(Player: Player)
	local Tool = ToolService:GetEquippedTool(Player)

	if Tool then
		Tool:Destroy()
	end
end

--[[ Remove todas as tools do Character e da Backpack do Player ]]
function ToolService:ClearPlayerTools(Player: Player)
	Player.Backpack:ClearAllChildren()
	ToolService:RemoveEquippedTool(Player)
end

--[[ Retorna o item da Data do player (Inventory) referente a Tool que ele está segurando na mao ]]
function ToolService:GetItemFromEquippedTool(Player: Player)
	local Tool = ToolService:GetEquippedTool(Player)

	if not Tool then
		return
	end

	local ToolId = Tool:GetAttribute("Id")
	if not ToolId then
		return
	end
	return InventoryService:GetItemById(ToolId)
end

-- [[ Carrega todas as tools que estão na Data do player (Inventory) ]]
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

function ToolService.KnitInit()
	for _, tool in script:GetDescendants() do
		if tool:IsA("ModuleScript") then
			ToolsModules[tool.Name] = tool
		end
	end
end

function ToolService.KnitStart()
	InventoryService = Knit.GetService("InvService")

	for _, tool in ToolsModules do
		if tool.Start then
			tool:Start(ToolsModules)
		end
	end
end

return ToolService
