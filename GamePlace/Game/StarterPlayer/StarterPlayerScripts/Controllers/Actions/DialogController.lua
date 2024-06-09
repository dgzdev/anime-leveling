local SoundService = game:GetService("SoundService")
local player = game.Players.LocalPlayer
local Mouse = player:GetMouse()
local AnswerDB = false

local MouseClickConnection = {}
local InDialog = false

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DialogController = Knit.CreateController({
	Name = "DialogController",
})

local DialogService

local PlayerGui = player:WaitForChild("PlayerGui")
local DialogueUI = PlayerGui:WaitForChild("Menu"):WaitForChild("Dialog")
local Content = DialogueUI:WaitForChild("Background"):WaitForChild("content")

local DialogBox = Content.Dialog
local AnswersContent = DialogueUI:WaitForChild("Background").AnswerBackground.content
local NPCNameTextArea = DialogueUI:WaitForChild("Background").NameBackground.NPC_Name

local WaitTimes = {
	[","] = 0.1,
	["."] = 0.25,
	["-"] = 0.1,
}

local TypeWriterSounds = {
	"rbxassetid://9120299506",
	"rbxassetid://9120299407",
	"rbxassetid://9120300060",
	"rbxassetid://9120299839",
	"rbxassetid://9120299839",
}

local function TypeWriterEffect(textToChange, text)
	for _, v in pairs(MouseClickConnection) do
		v:Disconnect()
	end

	local cnn
	cnn = Mouse.Button1Down:Once(function()
		if cnn then
			cnn:Disconnect()
		end
		clicked = true
	end)

	for i = 0, #text do
		if clicked then
			textToChange.Text = text

			clicked = false
			break
		end

		task.spawn(function()
			local Sound = Instance.new("Sound")
			Sound.SoundId = TypeWriterSounds[math.random(1, #TypeWriterSounds)]
			Sound.Parent = SoundService

			repeat
				task.wait()
			until Sound.IsLoaded
			Sound:Play()
			Sound.Played:Once(function()
				Sound:Destroy()
			end)
		end)

		textToChange.Text = string.sub(text, 1, i)
		task.wait(WaitTimes[text[i]] or 0.005)
	end

	if cnn then
		cnn:Disconnect()
		cnn = nil
	end
end

function UnloadAnswers()
	for i, v in ipairs(AnswersContent:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

function EndDialog()
	player.Character.HumanoidRootPart.Anchored = false
	UnloadAnswers()
	InDialog = false
	DialogueUI.Enabled = false

	DialogBox.Text = ""
	NPCNameTextArea.Text = ""
end

function BindAndLoadAnswers(DialogBody)
	NPCNameTextArea.Text = DialogBody.npcName or "forgot to add a name :/"
	UnloadAnswers()

	TypeWriterEffect(DialogBox, DialogBody.npcText)
	for answerIndex, AnswerTable in ipairs(DialogBody.Answers) do
		local AnswerPlaceholder = DialogueUI.AnswerPlaceholder:Clone() :: TextButton
		AnswerPlaceholder.Text = `{answerIndex} | {AnswerTable["text"]}`
		AnswerPlaceholder.Visible = true
		AnswerPlaceholder.Parent = AnswersContent

		AnswerPlaceholder.Activated:Once(function(inputObject, clickCount)
			if AnswerDB then
				return
			end
			AnswerDB = true
			task.delay(0.05, function()
				AnswerDB = false
			end)

			if AnswerTable.NextDialog then
				local newDialogBody = DialogService:Answer(answerIndex)

				if newDialogBody then
					BindAndLoadAnswers(newDialogBody)
				end
			else
				EndDialog()
			end
		end)
	end
end

function DialogController.KnitStart(_srvs)
	DialogService = Knit.GetService("DialogService")

	DialogService.CloseDialogEvent:Connect(function()
		EndDialog()
	end)

	DialogService.StartDialogEvent:Connect(function(DialogBody)
		if InDialog then
			return
		end

		InDialog = true
		DialogueUI.Enabled = true

		BindAndLoadAnswers(DialogBody)
	end)
end

return DialogController
