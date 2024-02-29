local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local ServerStorage = game:GetService("ServerStorage")

local InventoryService

local GameData = require(ServerStorage.GameData)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

local PlayerManager = require(script.PlayerManager)
local Managers: { [Player]: typeof(PlayerManager) | nil } = {}

-- ========================================
-- Connections
-- ========================================

function PlayerService.OnPlayerJoin(player: Player)
	local Manager = PlayerManager.new(player)
	local Profile = Manager:LoadProfile()
	if not Profile then
		return
	end

	Profile:ListenToRelease(function()
		Manager:Release()
		Managers[player] = nil
	end)

	Managers[player] = Manager
end

function PlayerService.OnPlayerLeave(player: Player)
	local Manager = Managers[player]
	if Manager then
		Manager:Release()
	end
end

-- ========================================
-- Client
-- ========================================

function PlayerService:GetData(player: Player)
	local Manager = Managers[player]
	if Manager then
		return Manager:GetData()
	end
end
function PlayerService.Client:GetData(...)
	return self.Server:GetData(...)
end

function PlayerService:EquipWeapon(player: Player, weaponId: number)
	if not weaponId then
		return error("No weaponId")
	end

	local Manager = Managers[player]
	if not Manager then
		return error("No manager")
	end

	local Slot = Manager:GetPlayerSlot()
	local Inventory: GameData.Inventory = Slot.Data.Inventory

	local weaponData = {}
	for weaponName, value in pairs(Inventory) do
		if value.Id == weaponId then
			weaponData = value
			weaponData.Name = weaponName
			break
		end
	end

	if not weaponData then
		return error("No weaponData")
	end

	Slot.Data.Equiped.Weapon = weaponData.Name
	Slot.Data.Equiped.Id = weaponData.Id

	InventoryService:EquipFromData(Slot.Data)
end

function PlayerService.Client:EquipWeapon(...)
	return self.Server:EquipWeapon(...)
end

-- ========================================
-- Knit
-- ========================================

function PlayerService:KnitStart()
	InventoryService = Knit.GetService("InventoryService")
end

Players.PlayerAdded:Connect(PlayerService.OnPlayerJoin)
Players.PlayerRemoving:Connect(PlayerService.OnPlayerLeave)

return PlayerService
