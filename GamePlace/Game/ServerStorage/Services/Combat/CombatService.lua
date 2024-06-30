local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
---caio was here
local PlayerService
local ProgressionService
local QuestService

local GameData = require(ServerStorage.GameData)

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {

	},
})

function CombatService:GetExperienceByName(EnemyHumanoid: Humanoid)
	return GameData.gameEnemies[EnemyHumanoid.Parent.Name].Experience
end

function CombatService:RegisterNPCEnemyKilledByPlayer(Character: Model, EnemyHumanoid: Humanoid)
	local Player = Players:GetPlayerFromCharacter(Character)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local PlayerQuests = QuestService:GetAllPlayerQuests(Player)

	local Experience = CombatService:GetExperienceByName(EnemyHumanoid)
	if not Experience then
		return
	end

	ProgressionService:AddExp(Players:GetPlayerFromCharacter(Character), Experience)

	for i, Quest in PlayerQuests do
		if not Quest then
			return
		end
		if Quest.questData.Type == "Kill Enemies" and EnemyHumanoid.Parent.Name == Quest.questData.EnemyName then
			PlayerData.Quests[i].questData.Amount -= 1
			if PlayerData.Quests[i].questData.Amount <= 0 then
				QuestService:FinishQuest(Player, Quest.questName, Quest.questData)
			end
			QuestService.Client.OnQuestUpdate:Fire(Player, Quest.questName, Quest.questData)
		end
	end
end

function CombatService:RegisterPlayerKilledByEnemy(enemy: Model, playerHumanoid: Humanoid)
	return
end

function CombatService:RegisterHumanoidKilled(Character: Model, EnemyHumanoid: Humanoid)
	if Players:GetPlayerFromCharacter(Character) then
		self:RegisterNPCEnemyKilledByPlayer(Character, EnemyHumanoid)
	else
		--> outra função.
		self:RegisterPlayerKilledByEnemy(Character, EnemyHumanoid)
	end
end

function CombatService.KnitStart()
	ProgressionService = Knit.GetService("ProgressionService")
	PlayerService = Knit.GetService("PlayerService")
	QuestService = Knit.GetService("QuestService")
end

return CombatService
