local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DramaticController




local TutorialController = Knit.CreateController({
	Name = "TutorialController",
})

function TutorialController:StartTutorial(Player)
    if not game:GetAttribute("Loaded") then
        game:GetAttributeChangedSignal("Loaded"):Wait()
    end

    DramaticController:ShowCutsceneBars()
    DramaticController:ShowDialogs("Teste", 1)
    DramaticController:ShowDialogs("Teste2",1)

    local Connection
    Connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.F then
            Connection:Disconnect()
            print("apertou")
        end
    end)
    local Connection2
    Connection2 = game.Players.LocalPlayer.Character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Tool") then
            Connection2:Disconnect()
            print("pegou a ferramenta")
        end
    end)



end

function TutorialController.KnitInit()
    DramaticController = Knit.GetController("DramaticController")
end

return TutorialController