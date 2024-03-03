local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService
local ProgressionService
local QuestService

local GameData = require(ServerStorage.GameData)

local CombatService = Knit.CreateService({
	Name = "CombatService",
	Client = {
		killedEnemy = Knit.CreateSignal(),
	},
})

function CombatService:RegisterNPCEnemyKilledByPlayer(Character: Model, EnemyHumanoid: Humanoid)
	print("recebeu", Character, EnemyHumanoid)

	local Player = Players:GetPlayerFromCharacter(Character)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local PlayerQuests = QuestService:GetAllPlayerQuests(Player)

	--print(EnemyHumanoid.Parent:GetAttribute("IsNPCEnemy"))

	if EnemyHumanoid:FindFirstAncestorWhichIsA("Model"):GetAttribute("Enemy") then
		local Data = EnemyHumanoid.Parent:FindFirstChild("Data")
		print(Data)

		if Data ~= nil then
			Data = require(EnemyHumanoid.Parent:FindFirstChild("Data"))
			local ExpPerHP = Data.Info.ExpPerOneHealthPoint
			if not ExpPerHP then
				return
			end
			print("b")
			ProgressionService:AddExp(Players:GetPlayerFromCharacter(Character), EnemyHumanoid.MaxHealth * ExpPerHP)
		else
			error("Enemy Data not found.")
		end

		for i, Quest in ipairs(PlayerQuests) do
			if not Quest then
				return
			end
			print(Quest.questData.Type)
			if Quest.questData.Type == "Kill Enemies" and EnemyHumanoid.Parent.Name == Quest.questData.EnemyName then
				PlayerData.Quests[i].questData.Amount -= 1
				print(PlayerData.Quests[i].questData.Amount)
				if PlayerData.Quests[i].questData.Amount <= 0 then
					warn("Quest Finished")
					QuestService:FinishQuest(Player, Quest.questName, Quest.questData)
				end

				--print(PlayerData.Quests[i].questData.Amount)
			end
		end
		self.Client.killedEnemy:Fire(Players:GetPlayerFromCharacter(Character))
	end
end

function CombatService:RegisterPlayerKilledByEnemy(enemy: Model, playerHumanoid: Humanoid)
	return
end

function CombatService:RegisterHumanoidKilled(Character: Model, EnemyHumanoid: Humanoid)
	if Players:GetPlayerFromCharacter(Character) then
		print("is a player")
		self:RegisterNPCEnemyKilledByPlayer(Character, EnemyHumanoid)
	else
		print("caiu outra funcao")
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
