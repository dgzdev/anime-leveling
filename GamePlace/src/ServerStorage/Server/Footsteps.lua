local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local footstepsModule = require(ReplicatedStorage:WaitForChild("FootstepsModule"))

local function checkSpeed(hum: Humanoid): boolean
	local speed = hum.WalkSpeed
	local move = hum.MoveDirection
	local floor = hum.FloorMaterial

	return (speed > 0 and move.Magnitude > 0 and floor ~= Enum.Material.Air)
end

local function getSpeed(hum: Humanoid): number
	return hum.WalkSpeed
end

local function getMaterial(material): string | nil
	local soundTable = footstepsModule:GetTableFromMaterial(material)
	if soundTable then
		local randomSound = footstepsModule:GetRandomSound(soundTable)

		if randomSound then
			return randomSound
		end
	end
end

local function shootRay(origin, direction, params): Enum.Material | nil
	local result = Workspace:Raycast(origin, direction, params)
	if result then
		return result.Material
	end
end

local function createFootstep(sound: Sound, character, rootPart: BasePart)
	local rayOrigin = rootPart.Position
	local rayDirection = Vector3.new(0, -5, 0)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { character }
	rayParams.IgnoreWater = false

	local rayResult = shootRay(rayOrigin, rayDirection, rayParams)

	if rayResult then
		local SoundID = getMaterial(rayResult)
		sound.SoundId = SoundID

		-- local Speed = getSpeed(character:WaitForChild("Humanoid")) / 16

		local newFootstep = sound:Clone()
		newFootstep.Name = "Footstep"
		newFootstep.PlaybackSpeed = 1 * math.random(90, 110) / 100

		newFootstep.Parent = rootPart
		newFootstep.SoundGroup = SoundService:WaitForChild("Character")

		newFootstep:Play()
		newFootstep.Ended:Once(function()
			newFootstep:Destroy()
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local Humanoid = character:WaitForChild("Humanoid")
		local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

		local Footstep = Instance.new("Sound")
		Footstep.Name = "Footstep"
		Footstep.SoundId = ""
		Footstep.Volume = 0.5

		Footstep.RollOffMaxDistance = 35
		Footstep.RollOffMinDistance = 15
		Footstep.RollOffMode = Enum.RollOffMode.InverseTapered

		Footstep.Parent = HumanoidRootPart

		while Humanoid.Health > 0 do
			task.wait(0.4)

			if checkSpeed(Humanoid) then
				createFootstep(Footstep, character, HumanoidRootPart)
			end
		end
	end)
end)

return {}
