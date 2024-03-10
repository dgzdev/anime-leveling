local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DungeonService = Knit.CreateService({
	Name = "DungeonService",
})
local DungeonAssets = ReplicatedStorage.Models.Dungeon
local DungeonFolder = game.Workspace:FindFirstChild("Dungeon")
local DungeonName = ""

local function GetDungeonAssets()
	return DungeonAssets[DungeonName]
end

function DungeonService:GetRandomRoom()
	local DungeonAssets = GetDungeonAssets()

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

function DungeonService:GetRandomDungeonRoom()
	local Rooms = DungeonFolder:GetChildren()
	return Rooms[math.random(1, #Rooms)]
end

function DungeonService:GetRandomDoor(Room)
	local Doors = Room.Doors:GetChildren()
	return Doors[math.random(1, #Doors)]
end

function DungeonService:PlaceBossRoom(BossRoom, LastRoom)
	local tries = 20

	local AnchorDoor
	local lastRoomTested = #DungeonFolder:GetChildren()
	while true do
		AnchorDoor = DungeonService:GetRandomDoor(LastRoom)
		BossRoom:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))

		if not DungeonService:CanPlace(AnchorDoor, BossRoom) then
			if tries <= 0 then
				tries = 20
				lastRoomTested -= 1
				LastRoom = DungeonFolder:GetChildren()[lastRoomTested]
			else
				tries -= 1
			end
		else
			break
		end

		task.wait()
	end

	if BossRoom:FindFirstChild("Doors") then
		BossRoom.Doors:Destroy()
	end
	local door2 = AnchorDoor:FindFirstChild("Door")

	if door2 then
		door2:Destroy()
	end
	BossRoom.Parent = DungeonFolder
end

function DungeonService:GenerateLinearDungeon(MIN_ROOMS: number, MAX_ROOMS: number)
	local ROOMS_AMOUNT = 15

	local StartRoom = GetDungeonAssets().Start
	StartRoom:PivotTo(CFrame.new(0, 400, 0))
	StartRoom.Parent = DungeonFolder

	local LastRoom = StartRoom

	local tries = 20
	local lastRoomTested = 0

	local roomIndex = 1
	while roomIndex <= ROOMS_AMOUNT do
		local Room = DungeonService:GetRandomRoom()
		local AnchorDoor: BasePart = DungeonService:GetRandomDoor(LastRoom)
		local RoomRandomDoor: BasePart = DungeonService:GetRandomDoor(Room)

		Room.PrimaryPart = RoomRandomDoor
		Room.Name = roomIndex

		Room:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))
		if not DungeonService:CanPlace(AnchorDoor, Room) then
			Room:Destroy()
			tries -= 1

			if tries <= 0 then
				if lastRoomTested == 0 then
					lastRoomTested = #DungeonFolder:GetChildren()
				end

				lastRoomTested -= 1
				LastRoom = DungeonFolder:GetChildren()[lastRoomTested]
				tries = 20
			end

			continue
		end

		local door1 = RoomRandomDoor:FindFirstChild("Door")
		local door2 = AnchorDoor:FindFirstChild("Door")
		if door1 then
			door1:Destroy()
		end
		if door2 then
			door2:Destroy()
		end

		tries = 20

		roomIndex += 1
		Room.Parent = DungeonFolder
		LastRoom = Room
		task.wait()
	end

	local BossRoom = GetDungeonAssets().Boss:Clone()
	BossRoom.PrimaryPart = BossRoom.Doors["1"]

	DungeonService:PlaceBossRoom(BossRoom, LastRoom)
end

function DungeonService.KnitInit()
	DungeonName = "Company"
	DungeonService:GenerateLinearDungeon(5, 10)
end
function DungeonService.KnitStart() end

return DungeonService
