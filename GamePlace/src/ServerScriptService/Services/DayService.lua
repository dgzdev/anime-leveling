local Lighting = game:GetService("Lighting")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DayService = Knit.CreateService({
	Name = "DayService",
	Client = {},
})

local stepRate = 1 / 30
local step = 0.05
local initialTime = math.random(400, 900)

function DayService:KnitStart()
	task.spawn(function()
		Lighting:SetMinutesAfterMidnight(initialTime)
		while true do
			task.wait(stepRate)
			Lighting:SetMinutesAfterMidnight(Lighting:GetMinutesAfterMidnight() + step)
		end
	end)
end

return DayService
