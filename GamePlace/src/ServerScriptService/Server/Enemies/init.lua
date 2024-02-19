local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EnemyManager = {
	Folder = Workspace:WaitForChild("Enemies"),
}
EnemyManager.Enemies = {}
EnemyManager.AI = require(script.EnemyAI)

local Assets = {
	["Enemy"] = "16441552144",
}

function EnemyManager:Init()
	local Enemies = self.Folder:GetChildren() :: EnemyFolder
	for _, Enemy in pairs(Enemies) do
		local Speed = Enemy:GetAttribute("Speed") or 16
		local Health = Enemy:GetAttribute("Health") or 100
		local Name = Enemy:GetAttribute("Name") or "Untitled Entity"
		local Inteligence = Enemy:GetAttribute("Inteligence") or 5

		local AI = self.AI.new(Enemy, {
			Speed = Speed,
			Health = Health,
			Name = Name,
			Inteligence = Inteligence,
		})

		local NPC_HUD = ReplicatedStorage:WaitForChild("Models"):WaitForChild("NPC_Info"):Clone()
		NPC_HUD.Parent = Enemy:WaitForChild("Head")
		NPC_HUD:WaitForChild("NPC_Name").Text = Name
		NPC_HUD:WaitForChild("NPC_Image").Image = "rbxassetid://" .. Assets.Enemy

		for _, part: BasePart in ipairs(Enemy:GetDescendants()) do
			if not (part:IsA("BasePart")) then
				continue
			end
			part.CollisionGroup = "Enemies"
		end

		AI:Init()
	end
end

EnemyManager:Init() --> Initiate the module.

export type EnemyFolder = {
	[number]: Model,
}
return EnemyManager
