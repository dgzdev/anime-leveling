local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Handler = {}
local Player = game.Players.LocalPlayer

-- Consts --
local SPEED_GATE = 2
local SPEED_MAXIMUM = 14
local MIN_DISTANCE = 0
local MAX_DISTANCE = 50

local FOOTSTEPS: Folder = ReplicatedStorage:WaitForChild("Footsteps")

local SKIN_VECTOR = Vector3.new(0.1, 0, 0.1)
local DELAY_UPPER = (0.1 * (SPEED_MAXIMUM / 17.5)) * (SPEED_MAXIMUM / SPEED_GATE)
local CharInfo = Player.Character or Player.CharacterAdded:Wait()
-- Vars --

local CAN_PLAY_SOUND = true
Handler.TerrainMaterialConversion = {
	[Enum.Material.Grass] = "Grass",
	[Enum.Material.Asphalt] = "Gravel",
	[Enum.Material.Mud] = "Ground",
	[Enum.Material.Ground] = "Dirt",
	[Enum.Material.Concrete] = "Concrete",
	[Enum.Material.CorrodedMetal] = "Metal_Solid",
	[Enum.Material.Metal] = "Metal",
	--[Enum.Material.Cobblestone] = ,
	[Enum.Material.Wood] = "Wood",
	[Enum.Material.WoodPlanks] = "Wood",
	[Enum.Material.Plastic] = "Tile",
	[Enum.Material.Sand] = "Sand",
	[Enum.Material.Sandstone] = "Sand",
	[Enum.Material.Snow] = "Snow",
	[Enum.Material.Slate] = "Concrete",
	[Enum.Material.Rock] = "Concrete",
	--[Enum.Material.Ice] = "Ice",
	--[Enum.Material.LeafyGrass] = "Grass",
	--[Enum.Material.Salt] = "Concrete",
	--[Enum.Material.Limestone] = "Concrete",
	[Enum.Material.Basalt] = "Concrete",
	--[Enum.Material.Pavement] = "Concrete",
	[Enum.Material.Brick] = "Brick",
	--[Enum.Material.Glacier] = "Ice",
}

Handler.LastMaterial = nil
Handler.LastNum = nil

function GetSelf()
	return Handler
end

local function FootstepLoop()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	--print(Character.HumanoidRootPart.AssemblyLinearVelocity.Y)
	for i, v in pairs(Character:WaitForChild("HumanoidRootPart"):GetChildren()) do
		if v:IsA("Sound") and not v:GetAttribute("Ignore") then
			v:Destroy()
		end
	end
	if Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		CAN_PLAY_SOUND = false
		--print(Character.Humanoid:GetState())
	end
	if Character:WaitForChild("Humanoid").Health <= 0 then
		return
	end

	local walkSpeed = Vector3.new(
		Character.HumanoidRootPart.AssemblyLinearVelocity.X,
		0,
		Character.HumanoidRootPart.AssemblyLinearVelocity.Z
	).Magnitude
	local delayTime = math.clamp(0.5 * (SPEED_MAXIMUM / walkSpeed), 0.1, DELAY_UPPER)

	if walkSpeed > SPEED_GATE then
		local HumanoidStateType = Character.Humanoid:GetState()
		local castParams = RaycastParams.new()
		castParams.FilterDescendantsInstances = { Character, workspace.CurrentCamera }
		castParams.FilterType = Enum.RaycastFilterType.Exclude
		castParams.RespectCanCollide = false

		local cast = workspace:Blockcast(
			CFrame.new(Character.HumanoidRootPart.Position),
			Character.HumanoidRootPart.Size - Vector3.new(0.1, 0, 0.1),
			Vector3.new(0, -4, 0) * (Character.Humanoid.HipHeight + 1),
			castParams
		) :: RaycastResult
		if cast then
			--if
			--	HumanoidStateType == Enum.HumanoidStateType.Jumping
			--	or HumanoidStateType == Enum.HumanoidStateType.FallingDown
			--	or HumanoidStateType == Enum.HumanoidStateType.Freefall
			--then
			--	return
			--end
			local soundOveride = cast.Instance:GetAttribute("Material")
				or Handler.TerrainMaterialConversion[cast.Material]
			--if cast.Instance.Name == "Wood Pallet" then
			--local NewPart = Instance.new("Part", workspace.DebugFolder)
			--NewPart.Shape = Enum.PartType.Ball
			--NewPart.Material = Enum.Material.Neon
			--NewPart.Size = Vector3.new(.5,.5,.5)
			--NewPart.Anchored = true
			--NewPart.CanCollide = false
			--NewPart.Position = cast.Position
			--end

			if soundOveride and CAN_PLAY_SOUND then
				local soundTable: table = FOOTSTEPS.Raw[soundOveride]:GetChildren()
				local newNum = math.random(#soundTable)
				if Handler.LastMaterial == soundOveride and #soundOveride ~= 1 then
					while newNum == Handler.LastNum do
						newNum = math.random(#soundTable)
					end
				end
				local sound: Sound = soundTable[newNum]:Clone()

				Handler.LastMaterial = soundOveride
				Handler.LastNum = newNum

				sound.Name = "step"
				sound.Volume = 0.33
				sound.RollOffMode = Enum.RollOffMode.Linear
				sound.RollOffMinDistance = MIN_DISTANCE
				sound.RollOffMaxDistance = MAX_DISTANCE
				sound.Parent = Character.HumanoidRootPart

				sound:Play()

				Debris:AddItem(sound, sound.TimeLength + 0.1)
			else
				print(cast.Material)
				--t("b")
				--ast.Instance == Workspace.Terrain then
				--if not TerrainMaterialConversion[cast.Material] then
				--end

				--local soundTable: table = FOOTSTEPS.Raw[TerrainMaterialConversion[cast.Material]]:GetChildren()
				--print(TerrainMaterialConversion[cast.Material], cast.Material)
				--local newNum = math.random(#soundTable)
				----if LastMaterial == soundOveride and #soundOveride ~= 1 then
				--while newNum == LastNum do
				--	newNum = math.random(#soundTable)
				--	print("while")
				--end
				----end
				--local sound: Sound = soundTable[newNum]:Clone()

				--LastMaterial = TerrainMaterialConversion[cast.Material]
				--LastNum = newNum

				--sound.Name = "step"
				--sound.Volume = 0.33
				--sound.RollOffMode = Enum.RollOffMode.Linear
				--sound.RollOffMinDistance = MIN_DISTANCE
				--sound.RollOffMaxDistance = MAX_DISTANCE
				--sound.Parent = Character.HumanoidRootPart
				--sound:Play()

				--Debris:AddItem(sound, sound.TimeLength + 0.1)
				--end
			end
		end
	end
	task.delay(delayTime, function()
		FootstepLoop()
		CAN_PLAY_SOUND = true
	end)
end

function Handler:Start()
	task.wait(0.1)
	FootstepLoop()
end

return Handler
