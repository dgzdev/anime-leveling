local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local QuestService = Knit.CreateService({
	Name = "QuestService",
	Client = {},
})

function QuestService:AcceptQuest(player: Player, questId: string)
	-- codigo chegou aqui
	return "OK"
end

function QuestService.Client:AcceptQuest(player: Player, questId: string)
	return self.Server:AcceptQuest(player, questId)
end

return QuestService
