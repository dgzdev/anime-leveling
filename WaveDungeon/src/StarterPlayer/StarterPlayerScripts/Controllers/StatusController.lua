local Knit = require(game.ReplicatedStorage.Packages.Knit)

local StatusController = Knit.CreateController({
	Name = "StatusController",
})

StatusController.Stamina = 100
StatusController.Mana = 100

function StatusController:GetStamina()
	return StatusController.Stamina
end

function StatusController:ReloadStamina()
	StatusController.Stamina = 100
end

function StatusController:WasteStamina(amount: number): boolean
	if StatusController.Stamina < amount then
		return false
	end
	StatusController.Stamina = StatusController.Stamina - amount
	return true
end

function StatusController:WasteMana(amount: number): boolean
	amount = math.ceil(amount)
	if StatusController.Mana < amount then
		return false
	end
	StatusController.Mana = math.clamp(StatusController.Mana - amount, 0, 100)
	return true
end

function StatusController:BindCharacter()
	local Player = game.Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	task.spawn(function()
		while true do
			local Last = StatusController.Stamina
			task.wait(1)

			if Last == StatusController.Stamina and StatusController.Stamina < 100 then
				StatusController.Stamina = math.clamp(StatusController.Stamina + 10, 0, 100)
			else
				Last = StatusController.Stamina
			end
		end
	end)
	task.spawn(function()
		while true do
			local Last = StatusController.Mana
			task.wait(1)

			if Last == StatusController.Mana and StatusController.Mana < 50 then
				StatusController.Mana = math.clamp(StatusController.Mana + 5, 0, 50)
			else
				Last = StatusController.Mana
			end
		end
	end)
end

function StatusController:KnitStart()
	coroutine.wrap(function()
		self:BindCharacter()
	end)()
end

return StatusController
