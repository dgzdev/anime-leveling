local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"))
local ServerStorage = game:GetService("ServerStorage")

local GameData = require(ServerStorage.GameData)

local ClothingService

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
	local Manager = PlayerManager.new(player)
	Manager:LoadProfile()

	print(Manager.Profile)

	if player:IsDescendantOf(Players) then
		if Manager.Profile then
			Manager.Profile:ListenToRelease(function()
				Manager:Release()
				Managers[player.UserId] = nil
			end)

			Managers[player.UserId] = Manager
		end
	end

	local Slot = Manager:GetPlayerSlot()
	local CharacterData = Slot.Character

	ClothingService:LoadCharacter(player, CharacterData)
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

function PlayerService:GetData(player: Player | Model)
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

function PlayerService.Client:GetData(player: Player)
	local data = self.Server:GetData(player)
	return data
end

function PlayerService:GetProfile(player)
	local Manager = Managers[player.UserId]

	if not Manager then
		repeat
			Manager = Managers[player.UserId]
			task.wait(1)
		until Manager
	end

	return Manager.Profile
end
function PlayerService.Client:GetProfile(player)
	local profile = self.Server:GetProfile(player)
	return profile.Data
end

function PlayerService.Client:ChangeSelectedSlot(player, Slot)
	local profile = self.Server:GetProfile(player).Data
	profile.Selected_Slot = Slot

	local SlotData = profile.Slots[Slot]
	print(SlotData)
	if SlotData == "false" then
		print(self.Server:GetSlotTemplate())
		profile.Slots[Slot] = self.Server:GetSlotTemplate()
	end
end

function PlayerService:GetSlotTemplate()
	return GameData.StarterSlot
end

function PlayerService.Client:GetSlotTemplate()
	return self.Server:GetSlotTemplate()
end

function PlayerService:GetSlot(player)
	local Manager = Managers[player.UserId]

	if not Manager then
		repeat
			Manager = Managers[player.UserId]
			task.wait(1)
		until Manager
	end

	return Manager:GetPlayerSlot()
end

function PlayerService.Client:GetData(player: Player)
	local data = self.Server:GetData(player)
	return data
end

-- ========================================
-- Knit
-- ========================================

function PlayerService:KnitStart()
	ClothingService = Knit.GetService("ClothingService")
end

game:BindToClose(function()
	for playerId: number, manager in pairs(Managers) do
		manager:Release()
	end
end)

Players.PlayerAdded:Connect(PlayerService.OnPlayerJoin)
Players.PlayerRemoving:Connect(PlayerService.OnPlayerLeave)

return PlayerService
