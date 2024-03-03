local Knit = require(game.ReplicatedStorage.Packages.Knit)

local QuestController = Knit.CreateController({
	Name = "QuestController",
})

local QuestService

local Player = game.Players.LocalPlayer
local PlayerGUI = Player:WaitForChild("PlayerGui")
local PromptUI = PlayerGUI:WaitForChild("Utils"):WaitForChild("Prompt")
local Background = PromptUI:WaitForChild("Background")

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
	PromptUI.Enabled = true
	Background.titleBackground.Title.Text = QuestData.Title or ""
	Background.message.Text = QuestData.Description or ""
end

function QuestController.KnitInit()
	QuestService = Knit.GetService("QuestService")
end

function QuestController.KnitStart()
	QuestService.PromptRequest:Connect(function(QuestData: {})
		print(QuestData)
		QuestController:CreatePrompt(QuestData)
		LockMouse(false)
	end)
end

return QuestController
