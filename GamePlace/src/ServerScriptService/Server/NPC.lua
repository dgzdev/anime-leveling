--!strict
--// @Author: SinceVoid

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Module = {}

local NPC = {}
NPC.__index = NPC

NPC.Names = {
	"Zaldir",
	"Aricen",
	"Tarek",
	"Valdur",
	"Darian",
	"Rylan",
	"Kaelen",
	"Zethan",
	"Eryndor",
	"Garrick",

	"Lirien",
	"Aradia",
	"Nalani",
	"Elara",
	"Sylara",
	"Kaelara",
	"Azura",
	"Rhiannon",
	"Lyanna",
	"Vaylara",
}

NPC.Surnames = {
	--// Short Surnames
	"Adam",
	"Alden",
	"Aldo",
	"Karl",
	"Pete",
	"Rolf",
	"Fefe",
	"Paul",
}

local Random = Random.new()
local function Spawn(f)
	if typeof(f) ~= "function" then
		return error("You need to pass a function.")
	end
	coroutine.wrap(f)()
end

function NPC.new(Character: Model)
	local self = setmetatable({}, NPC)

	--// Variables
	self.Character = Character
	self.Humanoid = Character:WaitForChild("Humanoid")
	self.HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	self.Config = {
		NPC_MoveRadius = 6,
		NPC_WaitTimeMin = 0,
		NPC_WaitTimeMax = 5,
		NPC_Speed = 6,
	}

	--// Prepare the NPC
	self:Prepare()

	--// Randomize the NPC name
	local Name = Character.Name
	self.Character.Name = Name
	self.Steps = 0
	self.SpawnPosition = self.HumanoidRootPart.Position

	--// Create the billboard
	local BillboardGui = ReplicatedStorage.Models.NPC_Info:Clone()
	BillboardGui.Parent = self.Character
	BillboardGui.Adornee = self.Character.Head
	BillboardGui.NPC_Name.Text = Name

	local IKControl = Instance.new("IKControl", self.Character)
	IKControl.EndEffector = self.Character:WaitForChild("Head")
	IKControl.ChainRoot = self.Character:WaitForChild("Head")
	IKControl.Type = Enum.IKControlType.LookAt
	IKControl.Enabled = false
	IKControl.SmoothTime = 0.1
	IKControl.Weight = 0.6
	self.IKControl = IKControl

	--// ProximityPrompt
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = Character
	ProximityPrompt.ActionText = "Talk"
	ProximityPrompt.ObjectText = Name
	ProximityPrompt.MaxActivationDistance = 5
	ProximityPrompt.RequiresLineOfSight = true
	ProximityPrompt.Name = "Talk"
	ProximityPrompt:SetAttribute("Theme", "NPC")
	ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		self:trigger(playerWhoTriggered)
	end)

	--[[
    -- ProximityPrompt Gui
    local Gui = ReplicatedStorage.Assets.Gui.Prompt:Clone()
    Gui.Parent = self.Character
    Gui.Adornee = self.HumanoidRootPart
    local Background = Gui.Background

    Background.Key.Text =  string.char(ProximityPrompt.KeyboardKeyCode.Value):upper()
    Background.Action.Text = ProximityPrompt.ActionText
    Background.Object.Text = ProximityPrompt.ObjectText

    self.ProximityGui = Gui]]
	self.ProximityPrompt = ProximityPrompt

	Spawn(function()
		self:MoveInRadius()
	end)

	return self
end

function NPC:trigger(player: Player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Head = Character:WaitForChild("Head")
	local IKControl = self.IKControl :: IKControl

	IKControl.Weight = 0
	self.Humanoid.WalkSpeed = 0

	TweenService:Create(IKControl, TweenInfo.new(1.2), {
		Weight = 0.7,
	}):Play()

	IKControl.Enabled = true
	IKControl.Target = Head

	task.wait(15)
	IKControl.Enabled = false
	self.Humanoid.WalkSpeed = self.Config.NPC_Speed
end

function NPC:Destroy()
	self.Character:Destroy()
end

function NPC:MoveInRadius()
	--[[
        Property: self.Config.NPC_MoveRadius :: number
        Moves the NPC in a radius around the current position
    ]]

	local MoveRadius = self.Config.NPC_MoveRadius
	local RandomPosition = self.HumanoidRootPart.Position
		+ Vector3.new(math.random(-MoveRadius, MoveRadius), 0, math.random(-MoveRadius, MoveRadius))

	-- Use pathfinding to find a path to the random position
	local Path = PathfindingService:CreatePath({
		AgentCanJump = true,
		AgentCanClimb = false,
	})

	if self.Steps % 5 == 0 then
		--// Every 5 steps, the NPC will return to the spawn position
		RandomPosition = self.SpawnPosition
	end

	Path:ComputeAsync(self.HumanoidRootPart.Position, RandomPosition)

	local Connection = Path.Blocked:Once(function(blockedWaypointIdx)
		--// Path is blocked, try again
		Path:ComputeAsync(self.HumanoidRootPart.Position, RandomPosition)
	end)

	-- Move the NPC along the path
	for _, Waypoint in pairs(Path:GetWaypoints()) do
		if Waypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		if Waypoint.Action == Enum.PathWaypointAction.Walk then
			self.Humanoid:MoveTo(Waypoint.Position)
		end

		task.wait()
	end

	--// Finished
	self.Steps += 1

	-- Randomize the wait time
	local WaitTime = Random:NextInteger(self.Config.NPC_WaitTimeMin, self.Config.NPC_WaitTimeMax)
	task.wait(WaitTime)
	Connection:Disconnect()
	self:MoveInRadius()
end

function NPC:Prepare()
	-- //

	--// Health Display
	self.Humanoid.HealthDisplayDistance = 0
	self.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	--// Display
	self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	self.Humanoid.DisplayName = ""

	--// Speed
	self.Humanoid.WalkSpeed = self.Config.NPC_Speed

	--// Sets the CollisionGroup to "NPC"
	table.foreachi(self.Character:GetDescendants(), function(_, Object)
		if Object:IsA("BasePart") then
			Object.CollisionGroup = "NPC"
		end
	end)
end

function Module.Start()
	local Folder = Workspace.NPC
	table.foreachi(Folder:GetChildren(), function(_, Character)
		local npc = NPC.new(Character)
	end)
end

return Module
