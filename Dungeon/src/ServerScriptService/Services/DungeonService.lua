local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local DungeonService = Knit.CreateService({
	Name = "DungeonService",
})

local EnemyService

local GameData = require(ServerStorage.GameData)
local DungeonAssets = ReplicatedStorage.Models.Dungeon
local DungeonFolder = game.Workspace:FindFirstChild("Dungeon")

local DungeonName = "Company"
local DungeonGenerated = false

local PastRooms = {}
local function GetDungeonAssets()
	return DungeonAssets[DungeonName]
end

function DungeonService:GetRandomRoom()
	local DungeonAssets = GetDungeonAssets()

	local Rooms = DungeonAssets.Rooms:GetChildren()
	local Room = Rooms[math.random(1, #Rooms)]
	--print(Room)
	return Room:Clone()
end

function DungeonService:CanPlace(AnchorDoor, Room, RoomLastName : string?)


	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = { Room, AnchorDoor.Parent }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.CollisionGroup = "ROOM"
	Params.RespectCanCollide = true

	local _cframe, _size = Room:GetBoundingBox()
	local size = _size - Vector3.new(2, 0, 2)
	local size = Vector3.new(math.round(size.X), math.round(size.Y), math.round(size.Z))
	local Hitbox = game.Workspace:GetPartBoundsInBox(_cframe, size, Params)

	--print(Hitbox)
	if #Hitbox > 0 then
		if RoomLastName then 
			--print(RoomLastName)
		end
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

function DungeonService:GetRoomDecoration(RoomName: string)
	local DungeonAssets = GetDungeonAssets()
	return DungeonAssets.Decorations:FindFirstChild(RoomName, true)
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

function DungeonService:GenerateLinearDungeon(MIN_ROOMS: number, MAX_ROOMS: number, RANK: string)
	if DungeonGenerated then
		return
	end
	DungeonGenerated = true
	local ROOMS_AMOUNT = math.random(MIN_ROOMS, MAX_ROOMS)

	local StartRoom = GetDungeonAssets().Start

	StartRoom:PivotTo(CFrame.new(0, 400, 0))
	StartRoom.Parent = DungeonFolder

	local LastRoom = StartRoom

	local tries = 20
	local lastRoomTested = 0
	local MobsAmount = 0
	local roomIndex = 1
	while roomIndex <= ROOMS_AMOUNT do
		local Room = DungeonService:GetRandomRoom()
		local RoomLastName
		print(LastRoom)
		local AnchorDoor: BasePart = DungeonService:GetRandomDoor(LastRoom)
		local RoomRandomDoor: BasePart = DungeonService:GetRandomDoor(Room)

		--print(Room.Name, RoomRandomDoor)
		Room.PrimaryPart = RoomRandomDoor
		RoomLastName = Room.Name
		Room.Name = roomIndex

		Room:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))

	if not DungeonService:CanPlace(AnchorDoor, Room, RoomLastName) then
		--print(RoomLastName)
		Room:Destroy()
		--print(tries)
		tries -= 1
		if tries <= 0 then
			if lastRoomTested == 0 then
				lastRoomTested = #DungeonFolder:GetChildren()
			end
			lastRoomTested -= 1
			LastRoom = DungeonFolder:GetChildren()[lastRoomTested]
			print(DungeonFolder:GetChildren()[lastRoomTested], lastRoomTested)
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
	--for i,v in pairs(Room:GetDescendants()) do
	--	table.insert(PastRooms, v)
	--end
	LastRoom = Room

		if roomIndex == "Start" then
			continue
		else
			--print(roomIndex)
			--=print(roomIndex * GameData.dungeonsData.RankSettings[RANK].damageMultiplierPerRoom)
			if not Room:FindFirstChild("EnemySpawn") then
				continue
			end
			local Progress = roomIndex / ROOMS_AMOUNT
			local ProgressToHundreds = Progress * 100
			local RandomEnemyType = math.random(1, ProgressToHundreds)
			local Spawns = Room:WaitForChild("EnemySpawn"):GetChildren()
			local EnemyRoomAmount = math.random(1, #Spawns)
			local colorA = Color3.new(0, 0, 1)
			local colorB = Color3.new(1, 0, 0)

			local final = colorA:Lerp(colorB, Progress)

			--print(final)

			--print(WillSpawnCrystal, (Progress + .4) * roomIndex)

			if roomIndex > 1 then
				for i = 1, EnemyRoomAmount, 1 do
					local WillSpawnCrystal = math.random(roomIndex * 0.5, 100 * Progress)

					if WillSpawnCrystal > (Progress + 1) * roomIndex then
						--  print(WillSpawnCrystal, (Progress + 1) * roomIndex, roomIndex)
					end
					local EnemyWillSpawn = math.random(1, #Spawns)
					local TargetPart = Spawns[EnemyWillSpawn]
					local EnemyRig = ReplicatedStorage.Essentials:WaitForChild("RIG"):Clone()

					local ang = math.random(-360, 360)

					if math.floor((ProgressToHundreds * MobsAmount) / 100) >= 140 then
						EnemyRig.Name = "Troll"
					elseif math.floor((ProgressToHundreds * MobsAmount) / 100) >= 80 then
						EnemyRig.Name = "Orc"
					else
						EnemyRig.Name = "Goblin"
					end
					EnemyRig.PrimaryPart.Anchored = true
					EnemyRig:PivotTo(TargetPart:GetPivot() * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, math.rad(ang), 0))
					task.wait()
					EnemyService:CreateEnemy(EnemyRig, {
						damage = roomIndex * GameData.dungeonsData.RankSettings[RANK].damageMultiplierPerRoom,
						health = roomIndex * GameData.dungeonsData.RankSettings[RANK].healthMultiplierPerRoom,
					})

					MobsAmount += 1

					task.delay(2, function()
						EnemyRig:PivotTo(
							TargetPart:GetPivot() * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, math.rad(ang), 0)
						)
						task.wait()
						EnemyRig.PrimaryPart.Anchored = false
					end)
				end
			end
		end

		task.wait()
	end

	local BossRoom = GetDungeonAssets().Boss:Clone()
	BossRoom.PrimaryPart = BossRoom.Doors["1"]

	DungeonService:PlaceBossRoom(BossRoom, LastRoom)
end

function DungeonService:GenerateDungeonFromRank(rank: string)
	local Rooms = {
		["E"] = 30,
		["D"] = 40,
		["C"] = 50,
		["B"] = 60,
		["A"] = 70,
		["S"] = 80,
	}
	local RoomAmount = Rooms[rank]
	self:GenerateLinearDungeon(RoomAmount - 10, RoomAmount, rank)
	DungeonGenerated = true
end

function DungeonService.KnitInit()
	task.spawn(function()
		EnemyService = Knit.GetService("EnemyService")

		DungeonName = "Company"
	end)
end
function DungeonService.KnitStart() end

return DungeonService
