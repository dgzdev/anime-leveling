local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {},
})

-- ===========================================================================
-- Configurações
-- ===========================================================================
local dbg: (...any) -> any = _G.print or print --> Debug print (Só funciona se o debug estiver ativado)

local cachedTools: {
	[string]: Tool,
} = {}

local Tools: {
	[string]: ToolDescription,
} = {}

export type ToolDescription = {
	name: string,
	description: string?,
	weight: number?,
	cooldown: number?,

	activate: (Tool, ...any) -> any,
	equip: (Tool, ...any) -> any,
	unequip: (Tool, ...any) -> any,
}

-- ===========================================================================\
-- Metadados
-- ===========================================================================
local Cooldowns: { [any]: number } = {}
Cooldowns.Set = function(self, key: any, value: number): number
	value = value or 1
	self[key] = tick() + value
	return self[key]
end
Cooldowns.Is = function(self, key: any): boolean
	return self[key] and self[key] > tick()
end

-- ===========================================================================
-- Funções
-- ===========================================================================
function ToolService:KnitInit() end

function ToolService:GetTool(name: string): (Tool, ToolDescription)
	assert(typeof(name) == "string", "Invalid argument #1 to 'GetTool' (string expected, got " .. typeof(name) .. ")")
	assert(Tools[name], "Tool '" .. name .. "' not found.")
	return cachedTools[name], Tools[name]
end

function ToolService:CreateFromDescription(description: ToolDescription): Tool
	assert(
		typeof(description) == "table",
		"Invalid argument #1 to 'CreateFromDescription' (table expected, got " .. typeof(description) .. ")"
	)
	assert(
		typeof(description.name) == "string",
		"Invalid argument #1 to 'CreateFromDescription' (string expected, got " .. typeof(description.name) .. ")"
	)

	local Tool = Instance.new("Tool")
	Tool.Name = description.name or "Unnamed Tool"

	for index, value in description do
		if typeof(value) == "function" then
			if not Tool[index] then
				return dbg("[TOOLS]: Invalid RBXScriptEvent: ", index, tostring(value))
			end

			Tool[index]:Connect(function(...)
				if description.cooldown then
					if Cooldowns:Is(description.name) then
						return dbg("Cooldown")
					end
					Cooldowns:Set(description.name, description.cooldown)
				end
				value(Tool, ...)
			end)
		else
			Tool:SetAttribute(index, value)
		end
	end
	return Tool
end

-- ===========================================================================
-- Carrega as ferramentas do jogo.
-- ===========================================================================
do
	for _, Tool in script:GetDescendants() do
		if not Tool:IsA("ModuleScript") then
			continue
		end

		local _v = require(Tool)
		local _t = ToolService:CreateFromDescription(_v)

		Tools[_v.name] = _v
		cachedTools[_v.name] = _t
	end
end

-- ===========================================================================
-- Inicializa o serviço.
-- ===========================================================================
do
	local toolNumber = 0
	for _i, _v in Tools do
		toolNumber += 1
	end
	dbg(`[TOOLS]: Loaded {toolNumber} tools.`)
end

return ToolService
