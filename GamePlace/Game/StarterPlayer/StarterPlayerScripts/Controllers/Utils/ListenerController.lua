local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEvent = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ClientListener = Knit.CreateController {
    Name = "ClientListener"
}

local TutorialController

local Handler = {
    ["CheckLoot"] = function(Data)
        print(Data)
    end
}

ClientEvent.OnClientEvent:Connect(function(callbackName, Data)
    if Handler[callbackName] then
        Handler[callbackName](Data)
    end
end)


function ClientListener.KnitInit()

    TutorialController = Knit.GetController("TutorialController")

    --> tutorial
    TutorialController:StartTutorial(game.Players.LocalPlayer)
end

return ClientListener



