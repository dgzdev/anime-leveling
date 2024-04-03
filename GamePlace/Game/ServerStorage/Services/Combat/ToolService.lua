local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ToolService = Knit.CreateService({
	Name = "ToolService",
	Client = {},
})

function ToolService:Initialize() end
function ToolService:KnitInit() end

-- ===========================================================================
-- SETTINGS
-- ===========================================================================
local debug: boolean = _G.Debug == true

local Tools = {}

-- ===========================================================================
-- Carrega as ferramentas do jogo.
-- ===========================================================================
do
	for _, Tool in script:GetDescendants() do
		if not Tool:IsA("ModuleScript") then
			continue
		end

		Tools[Tool.Name] = require(Tool)
	end
end

-- ===========================================================================
-- Inicializa o serviço.
-- ===========================================================================
do
	if debug then
		print(`[TOOL SERVICE] Loaded Tools: {#Tools}`)
	end

	ToolService:Initialize()
end

return ToolService
