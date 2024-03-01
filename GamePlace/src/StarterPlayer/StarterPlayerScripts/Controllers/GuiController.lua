local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService

local GuiController = Knit.CreateController({
	Name = "GuiController",
})

function GuiController:BindPlayerHud()
	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("PlayerHud")
	local frame = teste:WaitForChild("Background")

	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	local PlayerData = PlayerService:GetData(Players.LocalPlayer)

	local PlayerStatus = frame:WaitForChild("PlayerStatus")

	local healthPR: ImageLabel = PlayerStatus:FindFirstChild("healthPR", true)
	local Gradient: UIGradient = healthPR:WaitForChild("UIGradient")
	local healthValue: TextLabel = healthPR:FindFirstChild("healthValue", true)
	local levelValue: TextLabel = PlayerStatus:FindFirstChild("levelValue", true)

	local function transformInString(number: number): string
		return tostring(math.floor(number))
	end

	levelValue.Text = transformInString(PlayerData.Level)
	healthValue.Text = transformInString(Humanoid.Health)

	local function BindHumanoid()
		Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")

		Humanoid.HealthChanged:Connect(function()
			healthValue.Text = transformInString(Humanoid.Health)

			local health, maxHealth = Humanoid.Health, Humanoid.MaxHealth
			local healthPercent = health / maxHealth

			TweenService:Create(Gradient, TweenInfo.new(0.75, Enum.EasingStyle.Cubic), {
				Offset = Vector2.new(healthPercent, 0),
			}):Play()
		end)
	end

	BindHumanoid()
	Players.LocalPlayer.CharacterAdded:Connect(BindHumanoid)
end

function GuiController:KnitStart()
	local camera = Workspace.CurrentCamera

	local plrGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local teste = plrGui:WaitForChild("PlayerHud")
	local frame = teste:WaitForChild("Background")

	PlayerService = Knit.GetService("PlayerService")

	self:BindPlayerHud()

	local amt = -0.005
	local defaultFov = 60
	local fovScale = 60

	local lastCF = camera.CFrame
	task.spawn(function()
		while true do
			task.wait()
			local dif = (lastCF.Position - camera.CFrame.Position) * amt
			local max = 0.1

			frame.Position = UDim2.fromScale(0.5 - math.clamp(dif.X + dif.Z, 0, max), 0.5 - math.clamp(dif.Y, 0, max))

			local fov = camera.FieldOfView
			local dif2 = ((defaultFov - fov) / fovScale) / 4
			frame.Size = UDim2.fromScale(1 + dif2, 1 + dif2)

			lastCF = camera.CFrame
		end
	end)
end

return GuiController
