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
	DramaticController:ShowDialogs("Aperta F", -1)

	local function createInputConnection(keys: { Enum.KeyCode }, callback: (Enum.KeyCode) -> any)
		local Connection
		Connection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if table.find(keys, input.KeyCode) then
				Connection:Disconnect()
				callback(input.KeyCode)
			end
		end)
		return Connection
	end

	local function onSwordEquip()
		DramaticController:CheckDialog()
		task.wait(1)
		DramaticController:ShowDialogs("Parabéns!", -1)
		task.wait(1)
		DramaticController:ShowDialogs("Agora mate esse monstro!", 1)
		task.wait(2)
		DramaticController:HideCutsceneBars()
	end

	local function onKeyPress()
		DramaticController:CheckDialog()
		DramaticController:ShowDialogs("Nice!", 3)
		task.wait(2)
		DramaticController:ShowDialogs("Agora pegue a espada para me ajudar", -1)

		createInputConnection({ Enum.KeyCode.One }, onSwordEquip)
	end

	createInputConnection({ Enum.KeyCode.F }, onKeyPress)
end

function TutorialController.KnitInit()
	DramaticController = Knit.GetController("DramaticController")
end

return TutorialController
