local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DialogService = Knit.CreateService({
	Name = "DialogService",
	Client = {
		StartDialogEvent = Knit.CreateSignal(),
		CloseDialogEvent = Knit.CreateSignal(),
	},
})

local DialogData = {}

local Dialogs = {}

function DialogService:GetDialogTree(player, npc: string)
	local DialogTreeIndex
	local HighestPriority = 0
	for i, v in pairs(Dialogs[npc]) do
		if HighestPriority <= (v.priority or 0) then
			if v.validation then
				if not v.validation(player) then
					continue
				end
				DialogTreeIndex = i
				HighestPriority = v.priority or 0
			else
				DialogTreeIndex = i
				HighestPriority = v.priority or 0
			end
		end
	end

	return DialogTreeIndex
end

function DialogService:ClearBranch(branch: {})
	for i, answer in ipairs(branch.Answers) do
		if answer.ValidateAnswer then
			answer.ValidateAnswer = nil
		end
	end

	return branch
end

function DialogService:StartDialog(player, npc: string) -- start
	local dialogTrees = Dialogs[npc]

	if not DialogData[player] then
		DialogData[player] = {}
	end

	if not dialogTrees then
		return
	end
	local dialogTreeIndex = DialogService:GetDialogTree(player, npc)
	local DialogTree = dialogTrees[dialogTreeIndex]

	DialogData[player].npc = npc
	DialogData[player].DialogTreeIndex = dialogTreeIndex
	DialogData[player].DialogBody = 1

	local newDialogTree = table.clone(DialogTree[1])

	for i, answer in ipairs(newDialogTree.Answers) do
		if answer.ValidateAnswer == nil then
			continue
		end

		if answer.ValidateAnswer(player) == false then
			table.remove(newDialogTree.Answers, i)
		end
	end

	local ClearDialogTree = DialogService:ClearBranch(newDialogTree)

	DialogService.Client.StartDialogEvent:Fire(player, ClearDialogTree)
	return ClearDialogTree
end

function DialogService:Answer(player, answerIndex)
	local PlayerDialogData
	local DialogTree
	local DialogBody
	local Character = player.Character

	-- rever
	local successful, erro = pcall(function()
		PlayerDialogData = DialogData[player]
		DialogTree = Dialogs[PlayerDialogData.npc][PlayerDialogData.DialogTreeIndex]
		DialogBody = DialogTree[PlayerDialogData.DialogBody]
	end)

	if erro then
		return
	end

	local AnswerSelected = DialogBody.Answers[answerIndex]

	if not AnswerSelected then
		return print("not Answer")
	end

	if AnswerSelected.callback then
		AnswerSelected.callback(player)
	end

	if AnswerSelected.NextDialog then
		PlayerDialogData.DialogBody = AnswerSelected.NextDialog
	else
		PlayerDialogData.npc = ""
		PlayerDialogData.DialogTreeIndex = 0
		PlayerDialogData.DialogBody = 0
		return "EndDialog"
	end

	local NextDialog = DialogTree[AnswerSelected.NextDialog]

	local newDialogTree = table.clone(NextDialog)
	for i, answer in ipairs(newDialogTree.Answers) do
		if answer.ValidateAnswer == nil then
			continue
		end

		if answer.ValidateAnswer(player) == false then
			table.remove(newDialogTree.Answers, i)
		end
	end

	local ClearDialogTree = DialogService:ClearBranch(newDialogTree)

	return ClearDialogTree
end

function DialogService.Client:Answer(player, answerSelected)
	return self.Server:Answer(player, answerSelected)
end

function DialogService.Client:StartDialog(player, npc)
	return self.Server:StartDialog(player, npc)
end

function DialogService.KnitInit()
	for _, v in ipairs(game.ServerStorage.Index.Dialogs:GetChildren()) do
		if v:IsA("ModuleScript") then
			Dialogs[v.Name] = require(v)
		end
	end
end

function DialogService.KnitStart() end

return DialogService
