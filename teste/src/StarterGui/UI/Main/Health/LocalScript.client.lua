local pH = script.Parent:WaitForChild("PrimaryHP")

local HPInfo = script.Parent:WaitForChild("HPInfo")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid


local function Update()
	local health, maxHealth = humanoid.Health, humanoid.MaxHealth
	local div = health/maxHealth
	
	local df: Color3 = pH.BackgroundColor3
	if div <= 0.5 then
		df = Color3.fromRGB(229, 202, 0)
	elseif div <= 0.3 then
		df = Color3.fromRGB(229, 75, 75)
	else
		df = Color3.fromRGB(159, 229, 29)
	end
	
	game.TweenService:Create(pH, TweenInfo.new(.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false), {
		Size=UDim2.fromScale(div, 1),
		BackgroundColor3 = df
	}):Play()
	
	HPInfo.Text = ("%s/%s"):format(tostring(health), tostring(maxHealth))
end
Update()
humanoid.HealthChanged:Connect(function(health: number) 
	Update()	
end)
humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function(...: any) 
	Update()	
end)