local Player = game:GetService("Players").LocalPlayer
local SoundService = game:GetService("SoundService")
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

	for _, value: Sound in (RootPart:GetDescendants()) do
        if value:GetAttribute("Ignore") == true then
            continue
        end
		if not value:IsA("Sound") then
			continue
		end
		if value.Name == "Running" then
			value:Destroy()
		end

		value.SoundGroup = SoundService:WaitForChild("Character")
	end

RootPart.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") then
        if descendant:GetAttribute("Ignore") == true then
            return
        end
        if descendant.Name == "Running" then
            descendant:Destroy()
        end
        descendant.SoundGroup = SoundService:WaitForChild("Character")
    end
end)