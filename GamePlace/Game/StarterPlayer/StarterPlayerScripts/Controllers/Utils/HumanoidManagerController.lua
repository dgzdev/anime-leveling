local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local HumanoidManagerController = Knit.CreateController({
	Name = "HumanoidManagerController",
})

function HumanoidManagerController.GetAll(): { Humanoid }
	local v = {}
	for index, value in ipairs(Workspace:GetDescendants()) do
		if value:IsA("Humanoid") then
			table.insert(v, value)
		end
	end
	return v
end

function HumanoidManagerController:RunForAllHumanoidsExcept(callback: (humanoid: Humanoid) -> nil, ignore: Humanoid)
	local humanoids = HumanoidManagerController.GetAll()
	for index, humanoid in ipairs(humanoids) do
		if humanoid == ignore then
			continue
		end
		callback(humanoid)
	end
end

function HumanoidManagerController.KnitStart() end

return HumanoidManagerController
