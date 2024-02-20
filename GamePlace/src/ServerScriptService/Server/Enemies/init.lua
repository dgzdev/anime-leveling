local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local EnemyManager = {
	Folder = Workspace:WaitForChild("Enemies"),
}

local GameData = require(ServerStorage.GameData)

EnemyManager.Enemies = {}
EnemyManager.AI = require(script.EnemyAI)

function EnemyManager:Init()
	local Enemies = self.Folder:GetChildren() :: EnemyFolder

	local function BindForEnemy(Enemy: Model)
		table.insert(EnemyManager.Enemies, Enemy)

		local Name = Enemy:GetAttribute("Name") or Enemy.Name
		local EnemyInfo = GameData.gameEnemies[Name]

		local Speed = EnemyInfo.Speed or 16
		local Health = EnemyInfo.Health or 100

		local Inteligence = EnemyInfo.Inteligence or 5
		local Damage = EnemyInfo.Damage or 5
		local Hd = EnemyInfo.HumanoidDescription

		local AI = self.AI.new(Enemy, {
			Speed = Speed,
			Health = Health,
			Damage = Damage,
			Name = Name,
			HumanoidDescription = Hd,
			Inteligence = Inteligence,
			AnimationPack = EnemyInfo.AttackType,
		})

		AI.Died:Connect(function()
			local newEnemy = Enemy:Clone()
			newEnemy.Parent = ServerStorage

			task.wait(30)

			newEnemy.Parent = self.Folder
			local humanoid = newEnemy:WaitForChild("Humanoid") :: Humanoid
			humanoid.Health = humanoid.MaxHealth

			Enemy:Destroy()
			table.remove(EnemyManager.Enemies, table.find(EnemyManager.Enemies, Enemy))
		end)

		for _, part: BasePart in ipairs(Enemy:GetDescendants()) do
			if not (part:IsA("BasePart")) then
				continue
			end
			part.CollisionGroup = "Enemies"
		end

		AI:Init()
	end

	for _, Enemy in pairs(Enemies) do
		if table.find(EnemyManager.Enemies, Enemy) then
			continue
		end
		BindForEnemy(Enemy)
	end
	self.Folder.ChildAdded:Connect(function(Enemy: Model)
		if table.find(EnemyManager.Enemies, Enemy) then
			return
		end
		BindForEnemy(Enemy)
	end)
end

EnemyManager:Init() --> Initiate the module.

export type EnemyFolder = {
	[number]: Model,
}
return EnemyManager
