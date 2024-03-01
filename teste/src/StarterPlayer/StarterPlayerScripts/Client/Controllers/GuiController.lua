local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local GuiController = Knit.CreateController({
	Name = "GuiController",
})

function GuiController:KnitStart()
	local camera = Workspace.CurrentCamera

	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("teste")
	local frame = teste:WaitForChild("Background")

	local amt = -0.005
	local defaultFov = 60
	local fovScale = 0.15

	local lastCF = camera.CFrame
	task.spawn(function()
		while true do
			task.wait()
			local dif = (lastCF.Position - camera.CFrame.Position) * amt
			local max = 0.1

			frame.Position = UDim2.fromScale(0.5 - math.clamp(dif.X, 0, max), 0.5 - math.clamp(dif.Y, 0, max))

			local fov = camera.FieldOfView
			local dif2 = (defaultFov / fov) * fovScale
			frame.Size = UDim2.fromScale(1 - dif2, 1 - dif2)

			lastCF = camera.CFrame
		end
	end)
end

return GuiController
