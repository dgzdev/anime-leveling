local RunService = game:GetService("RunService")

local isStudio = RunService:IsStudio() == true

local globals = {
	Debug = false,
}
_G = globals

do --> ### Carrega as variaveis globais do servidor.
	if isStudio then
		globals.Debug = true
	end

	_G = globals

	if globals.Debug then
		return warn("[GLOBALS] Debug is enabled.")
	end
end
