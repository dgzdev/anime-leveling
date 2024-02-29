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
local Managers: { [number]: typeof(PlayerManager) | nil } = {}

-- ========================================
-- Connections
-- ========================================

function PlayerService.OnPlayerJoin(player: Player)
	print("PlayerService.OnPlayerJoin")
	local Manager = PlayerManager.new(player)
	Manager:LoadProfile()

	if player:IsDescendantOf(Players) then
		if Manager.Profile then
			Manager.Profile:ListenToRelease(function()
				Manager:Release()
				Managers[player.UserId] = nil
			end)

			Managers[player.UserId] = Manager
		end
	end

	local Data = Manager:GetData()

	Manager:LoadCharacterAppearance(player, Manager:GetPlayerSlot().Character)
	PlayerService:EquipWeapon(player, Data.Equiped.Id)
end

function PlayerService.OnPlayerLeave(player: Player)
	local Manager = Managers[player.UserId]
	if Manager then
		Manager:Release()
	end
end

-- ========================================
-- Client
-- ========================================

function PlayerService:GetData(player: Player)
	local Manager = Managers[player.UserId]

	if not Manager then
		repeat
			Manager = Managers[player.UserId]
			task.wait(1)
		until Manager
	end

	return Manager:GetData()
end
function PlayerService.Client:GetData(player: Player)
	return self.Server:GetData(player)
end

function PlayerService:EquipWeapon(player: Player, weaponId: number)
	if not weaponId then
		return error("No weaponId")
	end

	local Manager = Managers[player.UserId]
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

	return InventoryService:EquipFromData(player, Slot.Data)
end

function PlayerService.Client:EquipWeapon(Player: Player, weaponId: NumberSequence)
	return self.Server:EquipWeapon(Player, weaponId)
end

function PlayerService:GetWeapons()
	return GameData.gameWeapons
end

function PlayerService.Client:GetWeapons()
	return self.Server:GetWeapons()
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
