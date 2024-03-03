local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService

local GameData = require(ServerStorage.GameData)

local ProgressionService = Knit.CreateService({
	Name = "ProgressionService",
	Client = {
		LevelUp = Knit.CreateSignal(),
		ExpChanged = Knit.CreateSignal(),
	},
})

function ProgressionService:GetCurrentLevel(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	return PlayerData.Level
end

function ProgressionService:GetCurrentExperience(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	return PlayerData.Experience
end

function ProgressionService:ExpToNextLevel(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local Level = PlayerData.Level

	return math.floor(math.sqrt(100 * Level) * 10)
end

function ProgressionService:AddExp(Player, Amount)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local ExpToNextLevel = self:ExpToNextLevel(Player)
	local Character = Player.Character

	if Amount >= ExpToNextLevel or (PlayerData.Experience + Amount >= ExpToNextLevel) then
		PlayerData.Level += 1

		self:AddExp(Player, Amount - ExpToNextLevel)
		self.Client.LevelUp:Fire(Player, PlayerData.Level)
	end

	PlayerData.Experience += Amount

	self.Client.ExpChanged:Fire(Player, PlayerData.Experience, self:ExpToNextLevel(Player))
end

function ProgressionService.Client:GetCurrentLevel(Player)
	return self.Server:GetCurrentLevel(Player)
end

function ProgressionService.Client:GetCurrentExperience(Player)
	return self.Server:GetCurrentExperience(Player)
end

function ProgressionService.Client:ExpToNextLevel(Player)
	return self.Server:ExpToNextLevel(Player)
end

function ProgressionService.Client:AddExp(Player, Amount)
	return self.Server:AddExp(Player, Amount)
end

function ProgressionService.KnitInit()
	PlayerService = Knit.GetService("PlayerService")
end

return ProgressionService
