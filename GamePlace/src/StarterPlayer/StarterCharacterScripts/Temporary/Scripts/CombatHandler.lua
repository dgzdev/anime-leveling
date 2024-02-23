local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local AttackButtons = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Gamepad1 }
local DefendButtons = { Enum.UserInputType.MouseButton2, Enum.UserInputType.Gamepad2 }

local CombatHandler = {}
local Modules: Modules
local CombatModule: CombatModule

function CombatHandler:Init(modules: Modules)
	print("started")
	Modules = modules

	local combatModule = require(Modules.Combat)
	CombatModule = combatModule

	local Attack = combatModule.Attack
	local Defense = combatModule.Defense

	task.spawn(Attack.Init)
	task.spawn(Defense.Init)
end

local Weapons: WeaponsHandler = {
	["Sword"] = {
		["Attack"] = function(action, state, input)
			if state == Enum.UserInputState.Begin then
				Workspace:SetAttribute("Attacking", true)
			elseif state == Enum.UserInputState.End then
				Workspace:SetAttribute("Attacking", false)
			end
		end,
		["Defense"] = function(action, state, input)
			if state == Enum.UserInputState.Begin then
				CombatModule.Defense:ChangeDefenseState("Start")
			elseif state == Enum.UserInputState.End then
				CombatModule.Defense:ChangeDefenseState("End")
			end
		end,
	},
	["Melee"] = {
		["Attack"] = function() end,
		["Defense"] = function() end,
	},
}
CombatHandler.Weapons = Weapons

ContextActionService:BindAction("Attack", function(action, state, input)
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local WeaponType = Player:GetAttribute("WeaponType")

	if not WeaponType then
		return
	end

	if not Weapons[WeaponType] then
		return
	end

	if Character:GetAttribute("Defending") then
		return
	end

	Weapons[WeaponType].Attack(action, state, input)
end, true, table.unpack(AttackButtons))

ContextActionService:BindAction("Defend", function(action, state, input)
	if Workspace:GetAttribute("Attacking") then
		return
	end

	local Player = Players.LocalPlayer
	local WeaponType = Player:GetAttribute("WeaponType")

	if not WeaponType then
		return
	end

	if not Weapons[WeaponType] then
		return
	end

	Weapons[WeaponType].Defense(action, state, input)
end, true, table.unpack(DefendButtons))

-- ========================================================================================================
-- Exports
-- ========================================================================================================
export type WeaponsHandler = {
	[string]: {
		Attack: (action: string, state: Enum.UserInputState, input: InputObject) -> (),
		Defense: () -> (),
	},
}
export type Modules = {
	Combat: ModuleScript,
}
export type CombatModule = {
	Attack: {},
	Defense: {},
}
return CombatHandler
