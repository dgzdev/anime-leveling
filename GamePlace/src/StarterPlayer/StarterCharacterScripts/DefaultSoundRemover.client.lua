local Player = game:GetService("Players").LocalPlayer
local SoundService = game:GetService("SoundService")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

for _, value: Sound in ipairs(RootPart:GetDescendants()) do
	if not value:IsA("Sound") then
		continue
	end
	if value.Name == "Running" then
		value:Destroy()
	end

	value.SoundGroup = SoundService:WaitForChild("Character")
end
