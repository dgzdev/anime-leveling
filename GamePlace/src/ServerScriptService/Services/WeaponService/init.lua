local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService

local WeaponService = Knit.CreateService({
	Name = "WeaponService",
	Client = {},
})

local Weapons = {}

local GameData = require(ServerStorage.GameData)

function WeaponService:WeaponInput(
	Character: Model,
	ActionName: string,
	InputState: Enum.UserInputState,
	Data: { [any]: any }
)
	local PlayerData = PlayerService:GetData(Character)
	if not PlayerData then
		return
	end

	local EquippedItemName = PlayerData.Equiped.Weapon
	local itemData = GameData.gameWeapons[EquippedItemName]
	local NoSpaceName = EquippedItemName:gsub(" ", "")
	local WeaponType = Weapons[itemData.Type]

	if WeaponType[NoSpaceName] then
		if WeaponType[NoSpaceName][ActionName] then
			WeaponType[NoSpaceName][ActionName](Character, InputState, Data)
		elseif WeaponType.Default[ActionName] then
			Weapons.Default[ActionName](Character, InputState, Data)
		end
	elseif Weapons.Default[ActionName] then
		Weapons.Default[ActionName](Character, InputState, Data)
	end
end

function WeaponService.Client:WeaponInput(
	Player: Player,
	ActionName: string,
	InputState: Enum.UserInputState,
	Data: { [any]: any }
)
	local Character = Player.Character
	if not Character then
		return
	end

	self.Server:WeaponInput(Character, ActionName, InputState, Data)
end

function WeaponService.KnitInit()
	for _, weapon in ipairs(script:GetChildren()) do
		if not weapon:IsA("ModuleScript") then
			continue
		end
		Weapons[weapon.Name] = require(weapon)
	end
end
function WeaponService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")

	for _, weapon in pairs(Weapons) do
		if weapon.Start then
			weapon.Start()
		end
	end
end

return WeaponService
