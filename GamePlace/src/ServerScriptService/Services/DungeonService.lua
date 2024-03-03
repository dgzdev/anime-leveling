local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonService = Knit.CreateService({
	Name = "DungeonService",
})
local DungeonAssets = ReplicatedStorage.Models.Dungeon
local DungeonFolder = game.Workspace:FindFirstChild("Dungeon")

local function GetDungeonAssets(DungeonName: string)
	return DungeonAssets[DungeonName]
end

function DungeonService:GetRandomRoom(DungeonName: string)
	local DungeonAssets = GetDungeonAssets(DungeonName)

	local Rooms = DungeonAssets.Rooms:GetChildren()
	local Room = Rooms[math.random(1, #Rooms)]
	return Room:Clone()
end

function DungeonService:CanPlace(AnchorDoor, Room)
	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = { Room, AnchorDoor.Parent }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	local _cframe, _size = Room:GetBoundingBox()
	local size = _size - Vector3.new(2, 0, 2)
	local size = Vector3.new(math.round(size.X), math.round(size.Y), math.round(size.Z))
	local Hitbox = game.Workspace:GetPartBoundsInBox(_cframe, size, Params)
	if #Hitbox > 0 then
		return false
	end

	return true
end

function DungeonService:GetRandomDoor(Room)
	local Doors = Room.Doors:GetChildren()
	return Doors[math.random(1, #Doors)]
end

function DungeonService:GenerateLinearDungeon(DungeonName: string, MIN_ROOMS: number, MAX_ROOMS: number)
	local ROOMS_AMOUNT = 5

	local StartRoom = GetDungeonAssets(DungeonName).Start
	StartRoom:PivotTo(CFrame.new(0, 400, 0))
	StartRoom.Parent = DungeonFolder

	local LastRoom = StartRoom

	for roomIndex = 1, ROOMS_AMOUNT, 1 do
		local Room = DungeonService:GetRandomRoom(DungeonName)
		local AnchorDoor: BasePart = DungeonService:GetRandomDoor(LastRoom)
		local RoomRandomDoor: BasePart = DungeonService:GetRandomDoor(Room)

		Room.PrimaryPart = RoomRandomDoor

		Room:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))

		if not DungeonService:CanPlace(AnchorDoor, Room) then
			Room:Destroy()
			roomIndex -= 1
			continue
		end

		Room.Parent = DungeonFolder
		LastRoom = Room
	end

	local BossRoom = GetDungeonAssets(DungeonName).Boss
	local AnchorDoor = DungeonService:GetRandomDoor(LastRoom)
	BossRoom.PrimaryPart = BossRoom.Doors["1"]

	--verificar a se a sala do boss é valida
	local tries = 5
	while tries < 0 do
		if DungeonService:CanPlace(AnchorDoor, BossRoom) then
			BossRoom:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))
		end

		task.wait()
	end

	BossRoom.Parent = DungeonFolder
end

function DungeonService.KnitInit()
	-- DungeonService:GenerateLinearDungeon("Company", 5, 10)
end
function DungeonService.KnitStart() end

return DungeonService
