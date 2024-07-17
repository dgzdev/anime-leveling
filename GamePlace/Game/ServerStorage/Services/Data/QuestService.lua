local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService
local ProgressionService

local GameData = require(ServerStorage.GameData)

local QuestHandler = {}

--[[
	OnQuestReceive
	* nome: string
	* parametros: defeat 5 enemies :: Table

	OnQuestEnd
	* nome -> string

	OnQuestUpdate
	* nome -> string
	* parametros -> defeat 5 enemies
]]

local QuestService = Knit.CreateService({
	Name = "QuestService",
	Client = {
		OnQuestEnd = Knit.CreateSignal(), -- * terminou a quest
		OnQuestReceive = Knit.CreateSignal(), -- * recebeu uma quest
		OnQuestUpdate = Knit.CreateSignal(), --> atualizou a quest
		PromptRequest = Knit.CreateSignal(), -- * pedir para aceitar a quest
	},
})

function QuestService:GetAllPlayerQuests(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	return PlayerData.Quests
end

function QuestService:GetPlayerQuest(Player, questName)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	for i, v in PlayerData.Quests do
		if v.questName == questName then
			return i
		end
	end
end

function QuestService:FinishQuest(Player, questName, QuestData)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local IndexQuest = self:GetPlayerQuest(Player, questName)

	table.remove(PlayerData.Quests, IndexQuest)

	for RewardName, RewardAmount in QuestData.Rewards do
		--print(RewardName, RewardAmount)
		if RewardName == "Experience" then
			ProgressionService:AddExp(Player, RewardAmount)
		end
	end

	self.Client.OnQuestEnd:Fire(Player, questName)
end

function QuestService:GetQuestInfo(Player: Player, questName)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local QuestIndex = self:GetPlayerQuest(Player, questName)

	return PlayerData.Quests[QuestIndex]
end

function QuestService:PromptQuest(Player: Player, questName: string)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local QuestData = table.clone(GameData.gameQuests[questName]) -- importante dar table.clone()
	if QuestHandler[Player.Name] then
		return
	end

	if #PlayerData.Quests >= 5 then
		warn("You have max of quests (5)")
		return
	end

	if self:GetPlayerQuest(Player, questName) then
		warn("Already in this quest")
		return
	end

	QuestHandler[Player.Name] = {
		questName = questName,
		Accepted = false,
		Finished = false,
		questQueuePos = #PlayerData.Quests + 1,
		questData = QuestData,
	}

	-- quest data teria as informações da quest, como nome, descricao. Talvez o tipo e verificacoes de se a quest foi concluida.
	-- mas isso ai é cntg
	local questPrompt = GameData.questPrompts[questName]
	self.Client.PromptRequest:Fire(Player, questPrompt, QuestData)
end

function QuestService:DenyQuest(Player: Player)
	if not QuestHandler[Player.Name] then
		return
	end
	if not QuestHandler[Player.Name].questName then
		return
	end

	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	QuestHandler[Player.Name] = nil
	--PlayerData.Quest[QuestHandler[Player.Name].questQueuePos] = nil
end

function QuestService:AcceptQuest(Player: Player)
	-- codigo chegou aqui
	if not QuestHandler[Player.Name] then
		return
	end
	if not QuestHandler[Player.Name].questName then
		return
	end

	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	QuestHandler[Player.Name].Accepted = true

	table.insert(PlayerData.Quests, QuestHandler[Player.Name])

	self.Client.OnQuestReceive:Fire(Player, QuestHandler[Player.Name].questName, QuestHandler[Player.Name].questData)

	QuestHandler[Player.Name] = nil
end

function QuestService.Client:PromptQuest(Player: Player, questName: string)
	return self.Server:PromptQuest(Player, questName)
end

function QuestService.Client:AcceptQuest(Player: Player)
	return self.Server:AcceptQuest(Player)
end

function QuestService.Client:DenyQuest(Player: Player)
	return self.Server:DenyQuest(Player)
end

function QuestService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
	ProgressionService = Knit.GetService("ProgressionService")
end

return QuestService
