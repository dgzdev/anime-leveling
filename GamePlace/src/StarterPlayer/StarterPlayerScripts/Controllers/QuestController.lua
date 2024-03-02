local Knit = require(game.ReplicatedStorage.Packages.Knit)

local QuestController = Knit.CreateController({
    Name = "QuestController",
})

local QuestService

local Player = game.Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
local PromptUI = PlayerGUI:WaitForChild("Prompt")
local Connections = {}

local function ClearConnections()
	for i, v in Connections do
		v:Disconnect()
		Connections[i] = nil
	end
end

function QuestController:CreatePrompt(QuestData: {[string]: string})
    PromptUI.Enabled = true
	ClearConnections()

	PromptUI.titleBackground.Title.Text = QuestData.Title or ""
	PromptUI.message.Text = QuestData.Description or ""

    table.insert(Connections, PromptUI.Accept.Once:Connect(function()
        task.spawn(function()
			QuestService:AcceptQuest()
        end)
		PromptUI.Enabled = false
		ClearConnections()
    end))
	table.insert(Connections, PromptUI.Decline.Once:Connect(function()
        task.spawn(function()
			QuestService:DenyQuest()
        end)
		PromptUI.Enabled = false
		ClearConnections()
    end))
end

function QuestController.KnitInit()
    QuestService = Knit.GetService("QuestService")
end

function QuestController.KnitStart()
    QuestService.PromptRequest:Connect(function(QuestData: {})
    QuestController:CreatePrompt(QuestData)
    end)
end

return QuestController