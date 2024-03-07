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

		NewPoint = Knit.CreateSignal(),
		PointWasted = Knit.CreateSignal(),
	},
})

ProgressionService.LocalStatus = {
	["Inteligence"] = 0,
	["Strength"] = 0,
	["Agility"] = 0,
	["Endurance"] = 0,
}

function ProgressionService:GetCurrentLevel(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	return PlayerData.Level
end

function ProgressionService:GetPointsAvailable(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	return PlayerData.PointsAvailable
end

function ProgressionService:GetPointsDistribuition(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	return PlayerData.Points
end

function ProgressionService.Client:GetPointsDistribuition(Player)
	return self.Server:GetPointsDistribuition(Player)
end

function ProgressionService.Client:GetPointsAvailable(Player)
	return self.Server:GetPointsAvailable(Player)
end

function ProgressionService:GetCurrentExperience(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	return PlayerData.Experience
end

function ProgressionService:ApplyAvailablePoint(Player, PointType)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	if PlayerData.PointsAvailable < 1 then
		return false -- No points available
	end

	if not PlayerData.Points[PointType] then
		return false -- Invalid point type
	end

	PlayerData.Points[PointType] += 1
	PlayerData.PointsAvailable -= 1

	if self.LocalStatus[PointType] then
		self.LocalStatus[PointType] += 1
	end

	return true
end

function ProgressionService:ExpToNextLevel(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local Level = PlayerData.Level

	return math.floor(math.sqrt(100 * Level) * 10)
end

function ProgressionService:CalculateSpeed(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	--PlayerData.Points.Inteligence = math.floor(math.sqrt((PlayerData.Points.Inteligence + 1)))

	return function(Points)
		return math.floor(math.sqrt((PlayerData.Points.Inteligence + 1)))
	end
end

function ProgressionService:AddExp(Player, Amount)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local ExpToNextLevel = self:ExpToNextLevel(Player)
	local Character = Player.Character

	if Amount >= ExpToNextLevel or (PlayerData.Experience + Amount >= ExpToNextLevel) then
		PlayerData.Level += 1

		local Points = PlayerData.PointsAvailable or 0
		PlayerData.PointsAvailable = Points + 1
		print(PlayerData.PointsAvailable)

		self:AddExp(Player, Amount - ExpToNextLevel)
		self.Client.LevelUp:Fire(Player, PlayerData.Level)
	end

	PlayerData.Experience += Amount

	self.Client.ExpChanged:Fire(Player, PlayerData.Experience, self:ExpToNextLevel(Player))
end

function ProgressionService.Client:ApplyAvailablePoint(Player, PointType)
	return self.Server:ApplyAvailablePoint(Player, PointType)
end

function ProgressionService.Client:CalculateSpeed(Player)
	return self.Server:CalculateSpeed(Player)
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
