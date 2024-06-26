local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Workspace = game:GetService("Workspace")
local DungeonService = Knit.CreateService({
	Name = "DungeonService",
})

local EnemyService

local DoorsUsed = {}

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

	return Room:Clone()
end

function DungeonService:Can_Place(AnchorDoor, Room : Model, showLogs: boolean?)
	local Params = OverlapParams.new()
	local LimitsFolder = Room:FindFirstChild("Limits")
	Params.FilterDescendantsInstances = { Room, AnchorDoor.Parent }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.CollisionGroup = "LIMITS"
	local Hitbox = {}

	for i,v : BasePart in pairs(LimitsFolder:GetChildren()) do
		local c, s = v.CFrame, v.Size
		local H = game.Workspace:GetPartBoundsInBox(c,s, Params)
		if #H > 1 then
			for j,k in pairs(H) do
				table.insert(Hitbox, k)
			end
		end
	end

	if #Hitbox > 0 then
		if showLogs then
			print(Room,Hitbox)
		end
		return false
	end

	return true
end

function DungeonService:CanPlace(AnchorDoor, Room, showLogs: boolean?)
	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = { Room, AnchorDoor.Parent }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.CollisionGroup = "ROOM"

	local _cframe, _size = Room:GetBoundingBox()
	local size = _size - Vector3.new(0, 0, 0)
	local size = Vector3.new(math.round(size.X), math.round(size.Y), math.round(size.Z))
	local Hitbox = game.Workspace:GetPartBoundsInBox(_cframe, size, Params)

	if #Hitbox > 0 then
		if showLogs then
			print(Room,Hitbox)
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

		if not DungeonService:Can_Place(AnchorDoor, BossRoom) then
			if tries <= 0 then
				tries = 20
				lastRoomTested -= 1
				LastRoom = DungeonFolder:GetChildren()[lastRoomTested]
				self:PlaceBossRoom(BossRoom, LastRoom)
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

function DungeonService:ClearRoom(TargetRoom)
	if not TargetRoom:FindFirstChild("Limits") then return end
	for i,v in pairs(TargetRoom:FindFirstChild("Limits"):GetChildren()) do
		local Params = OverlapParams.new()
		Params.FilterDescendantsInstances = { TargetRoom }
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.RespectCanCollide = true

		local Hitbox = game.Workspace:GetPartBoundsInBox(v.CFrame, v.Size, Params)

		if Hitbox then
			for i,v in pairs(Hitbox) do
				if v and v.Name == "Door" then
					if not v:FindFirstAncestor("Doors") and not v:FindFirstAncestorWhichIsA("ObjectValue") and not v:FindFirstAncestor("Limits") then continue end
					local Room = v:FindFirstAncestor("Doors").Parent or v:FindFirstAncestorWhichIsA("ObjectValue").Value
					if not TargetRoom:GetAttribute("Secondary") and Room:GetAttribute("Secondary") then
						print(Room.Name)
						Room:Destroy()
						return
					elseif TargetRoom:GetAttribute("Secondary") and not Room:GetAttribute("Secondary") then
						print(TargetRoom.Name)
						TargetRoom:Destroy()
						return

					else
						print(Room.Name)
						Room:Destroy()
						return
					end
				end
			end
		end
	end
end

function DungeonService:GenerateLinearDungeon(MIN_ROOMS: number, MAX_ROOMS: number, RANK: string, GenerateSubRooms : boolean?)
	debug.profilebegin("Dungeon Generation")

	DungeonGenerated = true
	local ROOMS_AMOUNT = math.random(MIN_ROOMS, MAX_ROOMS)

	local StartRoom = GetDungeonAssets().Start:Clone()

	StartRoom:PivotTo(CFrame.new(0, 400, 0))
	StartRoom.Parent = DungeonFolder

	local LastRoom = StartRoom
	local LastRoomName
	local tries = 20
	local secondaryTries = 20
	local lastRoomTested = 0
	local MobsAmount = 0
	local roomIndex = 1

	while roomIndex <= ROOMS_AMOUNT do
		local Room = DungeonService:GetRandomRoom()

		local RoomLastName
		local RoomRandomDoor: BasePart = DungeonService:GetRandomDoor(Room)
		local AnchorDoor

		--Room.PrimaryPart = RoomRandomDoor
		--RoomLastName = Room.Name
		--Room.Name = roomIndex


		for i,v in pairs(GetDungeonAssets().Rooms:GetChildren()) do
			task.wait()
			print(Room.Name, RoomLastName)
			if RoomLastName == v.Name then continue end
			RoomRandomDoor = DungeonService:GetRandomDoor(v)
			Room = v:Clone()
			Room.PrimaryPart = RoomRandomDoor
			RoomLastName = Room.Name
			Room.Name = roomIndex

			local shouldBreak = false

			for j,k in pairs(LastRoom.Doors:GetChildren()) do
				AnchorDoor = k
				Room:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))
				if DungeonService:Can_Place(AnchorDoor, Room, false) then
					LastRoom = Room
					shouldBreak = true
					break
				end
			end
			if shouldBreak then
				break
			else
				DungeonFolder:ClearAllChildren()
				self:GenerateLinearDungeon(MIN_ROOMS, MAX_ROOMS, RANK, GenerateSubRooms)
				return
			end
		end



		--for i,v in pairs(LastRoom.Doors:GetChildren()) do
		--	task.wait()
		--	AnchorDoor = v
		--	Room:PivotTo(AnchorDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))
		--	if DungeonService:Can_Place(AnchorDoor, Room, false) then
		--		LastRoom = Room
		--		break
		--	else
		--		DungeonFolder:ClearAllChildren()
		--		self:GenerateLinearDungeon(MIN_ROOMS, MAX_ROOMS, RANK, GenerateSubRooms)
		--		return
		--	end
		--end


		local door1 = RoomRandomDoor:FindFirstChild("Door")
		local door2 = AnchorDoor:FindFirstChild("Door")
		table.insert(DoorsUsed, door1)
		table.insert(DoorsUsed, door2)
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

		if not roomIndex == "Start" then
			local Progress = roomIndex / ROOMS_AMOUNT
			local ProgressToHundreds = Progress * 100
			local RandomEnemyType = math.random(1, ProgressToHundreds)
			local Spawns = Room:WaitForChild("EnemySpawn"):GetChildren()
			local EnemyRoomAmount = math.random(1, #Spawns)
			local colorA = Color3.new(0, 0, 1)
			local colorB = Color3.new(1, 0, 0)

			local final = colorA:Lerp(colorB, Progress)

			do --> Enemy Generation
				if Room:FindFirstChild("EnemySpawn") then

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
			end
		end

		task.wait()
	end

	local BossRoom = GetDungeonAssets().Boss:Clone()
	BossRoom.PrimaryPart = BossRoom.Doors["1"]

	DungeonService:PlaceBossRoom(BossRoom, LastRoom)

	for RoomName, Room in pairs(DungeonFolder:GetChildren()) do
		local Amount  = 1
		if Room ~= "Start"  and GenerateSubRooms then
			if not DungeonFolder:FindFirstChild(RoomName) then
				continue
			end

			Room = DungeonFolder[RoomName]

			local DoorsAmount = Room.Doors:GetChildren()

		for i = 1, #DoorsAmount, 1 do
			task.wait()
			local DungeonTemplates = GetDungeonAssets().Rooms
			for RoomTypeName,RoomModel in pairs(DungeonTemplates:GetChildren()) do
				task.wait()
				local secondaryRoom = RoomModel:Clone()
				local AnchorSecondaryDoor
				while AnchorSecondaryDoor == nil and not table.find(DoorsUsed, AnchorSecondaryDoor) do
					if #LastRoom.Doors:GetChildren() <= 1 then
						--print(#LastRoom.Doors:GetChildren(), roomIndex)
						break
					end
					AnchorSecondaryDoor = DungeonService:GetRandomDoor(Room)
				end
				if AnchorSecondaryDoor then
					local SecondaryRoomRandomDoor = DungeonService:GetRandomDoor(secondaryRoom)
					secondaryRoom.PrimaryPart = SecondaryRoomRandomDoor
					secondaryRoom.Name = Room.Name .. "." .. SecondaryRoomRandomDoor.Name

					secondaryRoom:PivotTo(AnchorSecondaryDoor:GetPivot() * CFrame.Angles(0, math.rad(180), 0))

					if not DungeonService:Can_Place(AnchorSecondaryDoor, secondaryRoom) then
						secondaryRoom:Destroy()

					else
						table.insert(DoorsUsed, AnchorSecondaryDoor)
						secondaryRoom:SetAttribute("Secondary", true)
						secondaryRoom.Parent = DungeonFolder
						local door1 = SecondaryRoomRandomDoor:FindFirstChild("Door")
						local door2 = AnchorSecondaryDoor:FindFirstChild("Door")
						if door1 then
							door1:Destroy()
						end
						if door2 then
							door2:Destroy()
						end
					end
					continue
				else
					--print(AnchorSecondaryDoor, LastRoom)
					secondaryRoom:Destroy()
					continue
				end
			end
		end
		end
		Amount += 1
	end

	debug.profileend()
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
	self:GenerateLinearDungeon(RoomAmount - 10, RoomAmount, rank, false)
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
