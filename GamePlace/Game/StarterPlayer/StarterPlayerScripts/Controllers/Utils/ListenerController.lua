local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEvent = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ListenerController = Knit.CreateController({
	Name = "ListenerController",
})

local TutorialController

local Handler = {
	["CheckLoot"] = function(Data)
		print(Data)
	end,
}

ClientEvent.OnClientEvent:Connect(function(callbackName, Data)
	if Handler[callbackName] then
		Handler[callbackName](Data)
	end
end)

function ListenerController.KnitStart()
	TutorialController = Knit.GetController("TutorialController")
	TutorialController:StartTutorial(game.Players.LocalPlayer)
end

return ListenerController
