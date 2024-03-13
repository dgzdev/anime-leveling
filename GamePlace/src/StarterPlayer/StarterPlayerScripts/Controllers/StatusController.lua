local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Stamina = Instance.new("NumberValue")
Stamina.Name = "Stamina"
Stamina.Value = 100

local Mana = Instance.new("NumberValue")
Mana.Name = "Mana"
Mana.Value = 50

local StatusController = Knit.CreateController({
	Name = "StatusController",
})

function StatusController:GetStamina()
	return Stamina.Value
end

function StatusController:WasteStamina(amount: number): boolean
	if Stamina.Value < amount then
		return false
	end
	Stamina.Value = math.clamp(Stamina.Value - amount, 0, 100)
	return true
end

function StatusController:WasteMana(amount: number): boolean
	if Mana.Value < amount then
		return false
	end
	Mana.Value = math.clamp(Mana.Value - amount, 0, 100)
	return true
end

function StatusController:BindCharacter()
	local Player = game.Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	task.spawn(function()
		while true do
			local Last = Stamina.Value
			task.wait(1)

			if Last == Stamina.Value and Stamina.Value < 100 then
				Stamina.Value = math.clamp(Stamina.Value + 10, 0, 100)
			else
				Last = Stamina.Value
			end
		end
	end)
	task.spawn(function()
		while true do
			local Last = Mana.Value
			task.wait(1)

			if Last == Mana.Value and Mana.Value < 50 then
				Mana.Value = math.clamp(Mana.Value + 5, 0, 50)
			else
				Last = Mana.Value
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
