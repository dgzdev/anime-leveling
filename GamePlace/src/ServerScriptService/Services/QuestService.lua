local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService

local GameData = require(ServerStorage.GameData)

local QuestHandler = {}

local QuestService = Knit.CreateService({
	Name = "QuestService",
	Client = {
		OnQuestEnd = Knit.CreateSignal(),
		PromptRequest = Knit.CreateSignal(),
	},
})

function QuestService:GetAllPlayerQuests(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	return PlayerData.Quest
end

function QuestService:GetPlayerQuest(Player, questName)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)

	for i, v in pairs(PlayerData.Quest) do
		if v.questName == questName then
			return i
		end
	end
end

function QuestService:FinishQuest(Player, questName)
	local PlayerData = PlayerService:GetData(Player)
	local IndexQuest = self:GetPlayerQuest(Player, questName)

	table.remove(PlayerData.Quest, IndexQuest)

	self.Client.OnQuestEnd:Fire(Player, questName)
end

function QuestService:GetQuestInfo(questName)
	
end

function QuestService:PromptQuest(Player: Player, questName: string)
	if QuestHandler[Player.Name].Accepted then
		return
	end
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	QuestHandler[Player.Name] = {
		questName = questName,
		Accepted = false,
		Finished = false,
		questQueuePos = #PlayerData.Quest + 1,
	}

	-- quest data teria as informações da quest, como nome, descricao. Talvez o tipo e verificacoes de se a quest foi concluida.
	-- mas isso ai é cntg
	local QuestData = GameData.gameQuests[questName]
	self.Client.PromptRequest:Fire(Player, QuestData)
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

	table.insert(PlayerData.Quest, QuestHandler[Player.Name])

end

function QuestService.Client:PromptQuest(Player: Player, questName: string)
	return QuestService.Server:PromptQuest(Player, questName)
end

function QuestService.Client:AcceptQuest(Player: Player)
	return QuestService.Server:AcceptQuest(Player)
end

function QuestService.Client:DenyQuest(Player: Player)
	return QuestService.Server:DenyQuest(Player)
end

function QuestService.KnitInit()
	PlayerService = Knit.GetService("PlayerService")
end

return QuestService
