local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local character = player.Character or player.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local playerHealth = script.Parent.Parent :: BillboardGui
local PrimaryHP = script.Parent:WaitForChild("PrimaryHP")
local Background = script.Parent
local SecondaryHP = script.Parent:WaitForChild("SecondaryHP")
local Stroke = Background:WaitForChild("UIStroke")

playerHealth.Parent = character:WaitForChild("HumanoidRootPart")

Background.BackgroundTransparency = 1
SecondaryHP.BackgroundTransparency = 1
PrimaryHP.BackgroundTransparency = 1
Stroke.Transparency = 1

humanoid.HealthChanged:Connect(function(health: number)
	local maxHealth = humanoid.MaxHealth
		
	Background.BackgroundTransparency = .5
	SecondaryHP.BackgroundTransparency = .3
	PrimaryHP.BackgroundTransparency = .3
	Stroke.Transparency = 0
		
	TweenService:Create(PrimaryHP, TweenInfo.new(0.25), {
		Size = UDim2.fromScale(1,health/maxHealth),
	}):Play()
	TweenService:Create(SecondaryHP, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.35), {
		Size = UDim2.fromScale(1, health/maxHealth)
	}):Play()
	
	if (health == maxHealth) then
		task.wait(1.25)
		if (health == maxHealth) then
			TweenService:Create(PrimaryHP, TweenInfo.new(.1), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(Background, TweenInfo.new(.1), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(SecondaryHP, TweenInfo.new(.1), {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(Stroke, TweenInfo.new(.1), {
				Transparency = 1
			}):Play()
		end
	end
end)

humanoid.Died:Once(function()
	playerHealth:Destroy()
end)