--!strict
--// @Author: SinceVoid

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameData = require(ServerStorage.GameData)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Module = Knit.CreateService({
	Name = "NPCService",
	Client = {},
})

local QuestService

local NPC = {}
NPC.__index = NPC

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
	self.Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	self.HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	self.Config = {
		NPC_MoveRadius = 6,
		NPC_WaitTimeMin = 0,
		NPC_WaitTimeMax = 5,
		NPC_Speed = 6,
	}

	if GameData.npcQuests[Character.Name] then
		self.Quest = GameData.npcQuests[Character.Name]
		local questData = GameData.questPrompts[self.Quest]

		self.Humanoid.WalkSpeed = 0
		self.Humanoid.JumpPower = 0

		Character:SetAttribute("Quest", self.Quest)
		Character:SetAttribute("Title", questData.Title)
		Character:SetAttribute("Description", questData.Description)
	end

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

	self.Dialog = GameData.gameDialogs[Name] or { "No dialog" }

	ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if self.Quest then
			QuestService:PromptQuest(playerWhoTriggered, self.Quest)
		else
			--> puxar dialogo
			ReplicatedStorage.Events.NPC:FireClient(playerWhoTriggered, {
				NPC = self.Character,
				Dialogs = self.Dialog,
				Title = Name,
			})
		end
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
		if not self.Quest then
			self:MoveInRadius()
		end
	end)

	return self
end

function NPC:trigger(player: Player)
	self.Humanoid.WalkSpeed = 0

	task.wait(15)
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
	--// Health Display
	self.Humanoid.HealthDisplayDistance = 0
	self.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	--// Display
	self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	self.Humanoid.DisplayName = ""

	local HumanoidDescription = self.Character:FindFirstChildWhichIsA("HumanoidDescription") :: HumanoidDescription
	if HumanoidDescription then
		self.Humanoid:ApplyDescription(HumanoidDescription)
	end

	--// Speed
	self.Humanoid.WalkSpeed = self.Config.NPC_Speed

	--// Sets the CollisionGroup to "NPC"
	for _, Object in ipairs(self.Character:GetDescendants()) do
		if Object:IsA("BasePart") then
			Object.CollisionGroup = "NPC"
		end
	end
end

function Module.KnitStart()
	local Folder = Workspace.NPC
	for _, value in ipairs(Folder:GetChildren()) do
		NPC.new(value)
	end

	QuestService = Knit.GetService("QuestService")
end

return Module
