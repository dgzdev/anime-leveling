local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonService = Knit.CreateService({
	Name = "DungeonService",
})
local DungeonAssets = ReplicatedStorage.Models.Dungeon

local function GetDungeonAssets(DungeonName: string)
	return DungeonAssets[DungeonAssets]
end

function DungeonService:GetRandomRoom(DungeonName: string)
	local DungeonAssets = GetDungeonAssets(DungeonName)

	local Rooms = DungeonAssets.Rooms:GetChildren()
	local Room = Rooms[math.random(1, #Rooms:GetChildren())]
	return if Room.Name == "Boss" or Room.Name == "Start" then DungeonService:GetRandomRoom(DungeonName) else Room
end

function DungeonService:CanPlace(Room: Model)

end

function DungeonService:GetRandomDoor(Room: Model)
end


function DungeonService:GenerateLinearDungeon(DungeonName: string, MIN_ROOMS: number, MAX_ROOMS: number)
	local ROOMS_AMOUNT = math.random(MIN_ROOMS, MAX_ROOMS)


end


function DungeonService.KnitInit()
	-- DungeonService:GenerateLinearDungeon("Company", 5, 10)
end
function DungeonService.KnitStart() end

return DungeonService
