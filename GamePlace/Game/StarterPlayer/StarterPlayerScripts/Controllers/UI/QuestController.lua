local Knit = require(game.ReplicatedStorage.Packages.Knit)

local QuestController = Knit.CreateController({
	Name = "QuestController",
})

local QuestService

local Player = game.Players.LocalPlayer

local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")

local Connections = {}

local function LockMouse(boolean: boolean)
	if boolean then
		CameraEvent:Fire("Lock")
	else
		CameraEvent:Fire("Unlock")
	end
end

function QuestController:CreatePrompt(QuestData: { [string]: string })
	local PlayerGUI = Player:WaitForChild("PlayerGui")
	local PromptUI = PlayerGUI:WaitForChild("Utils"):WaitForChild("Prompt")
	local Background = PromptUI:WaitForChild("Background")

	PromptUI.Enabled = true
	Background.titleBackground.Title.Text = QuestData.Title or ""
	Background.message.Text = QuestData.Description or ""
end

function QuestController.KnitStart()
	QuestService = Knit.GetService("QuestService")

	coroutine.wrap(function()
		QuestService.PromptRequest:Connect(function(questPrompt: {})
			QuestController:CreatePrompt(questPrompt)
			LockMouse(false)
		end)
	end)()
end

return QuestController
