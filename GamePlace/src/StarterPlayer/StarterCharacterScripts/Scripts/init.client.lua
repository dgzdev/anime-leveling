local ModuleManager = {}

if not (game:IsLoaded()) then
	game.Loaded:Wait()
end

local Modules: { [number]: ModuleScript } = script:GetChildren()

ModuleManager.EnableModule = function(self, Module: ModuleScript)
	if Module:IsA("ModuleScript") == false then
		return
	end
	task.spawn(function()
		require(Module)
	end)
end

for _, Module in ipairs(Modules) do
	ModuleManager:EnableModule(Module)
end

export type Module = {}

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
