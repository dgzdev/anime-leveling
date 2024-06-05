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
	local WeaponTypeModule = Weapons[itemData.Type]
	local WeaponNameModule = Weapons[NoSpaceName]

	if WeaponNameModule[ActionName] then
		WeaponNameModule[ActionName](Character, InputState, Data)
		return
	end

	if WeaponTypeModule[ActionName] then
		WeaponTypeModule[ActionName](Character, InputState, Data)
		return
	end

	if Weapons.Default[ActionName] then
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

function WeaponService:GetOverlapParams(Character)
	local op = OverlapParams.new()
	if Character:GetAttribute("Enemy") then
		local Characters = {}
		for _, plrs in (Players:GetPlayers()) do
			table.insert(Characters, plrs.Character)
		end

		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = Characters
	else
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { workspace:WaitForChild("Enemies") }
	end

	return op
end

function WeaponService.KnitInit()
	for _, weapon in (script:GetChildren()) do
		if not weapon:IsA("ModuleScript") then
			continue
		end
		Weapons[weapon.Name] = require(weapon)
	end
end
function WeaponService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")

	for _, weapon in Weapons do
		if weapon.Start then
			weapon.Start(Weapons.Default)
		end
	end
end

return WeaponService
