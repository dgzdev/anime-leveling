local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local InventoryService
local ClothingService
local ProgressionService
local DungeonService

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
	task.spawn(function()
		local joinData = player:GetJoinData()
		local teleportData = joinData.TeleportData
		local rank = teleportData.Rank or "E"
		DungeonService:GenerateDungeonFromRank(rank)
	end)

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

	Data.Inventory = GameData.defaultInventory
	Data.Hotbar = GameData.profileTemplate.Slots[1].Data.Hotbar
	Data.Equiped = GameData.profileTemplate.Slots[1].Data.Equiped
	Data.SkillsTreeUnlocked = GameData.profileTemplate.Slots[1].Data.SkillsTreeUnlocked

	local Character = player.Character or player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	Humanoid.MaxHealth = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)
	Humanoid.Health = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)

	ProgressionService:UpdateLocalStatus(player)
	player.CharacterAdded:Connect(function(character)
		ClothingService:LoadCharacter(player, Manager:GetPlayerSlot().Character)
		PlayerService:EquipWeapon(player, Data.Equiped.Id)

		Character = player.Character or player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")

		Humanoid.MaxHealth = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)
		Humanoid.Health = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)
	end)

	ClothingService:LoadCharacter(player, Manager:GetPlayerSlot().Character)
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

function PlayerService:GetData(player: Player | Model): GameData.SlotData
	local Player: Player = player
	if player:IsA("Model") then
		if Players:GetPlayerFromCharacter(player) then
			Player = Players:GetPlayerFromCharacter(player)
		else
			local Data = Player:FindFirstChild("Data")
			if Data then
				return require(Data)
			end
		end
	end

	local Manager = Managers[Player.UserId]

	if not Manager then
		repeat
			Manager = Managers[Player.UserId]
			task.wait(1)
		until Manager
	end

	return Manager:GetData()
end

function PlayerService:GetSlot(player: Player)
	local Manager = Managers[player.UserId]
	if not Manager then
		return error("No manager")
	end

	return Manager:GetPlayerSlot()
end

function PlayerService.Client:GetData(player: Player)
	local data = self.Server:GetData(player)
	return data
end

function PlayerService:Respawn(player: Player)
	player:LoadCharacter()
end

function PlayerService.Client:Respawn(player: Player)
	return self.Server:Respawn(player)
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
	for weaponName, value in Inventory do
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

function PlayerService:KnitInit()
	InventoryService = Knit.GetService("InventoryService")
	ClothingService = Knit.GetService("ClothingService")
	ProgressionService = Knit.GetService("ProgressionService")
	DungeonService = Knit.GetService("DungeonService")
end

function PlayerService:KnitStart() end

game:BindToClose(function()
	for playerId: number, manager in Managers do
		manager:Release()
	end
end)

Players.PlayerAdded:Connect(PlayerService.OnPlayerJoin)
Players.PlayerRemoving:Connect(PlayerService.OnPlayerLeave)

return PlayerService
