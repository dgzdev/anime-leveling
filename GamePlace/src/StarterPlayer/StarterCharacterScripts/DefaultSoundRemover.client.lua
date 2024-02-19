local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

for _, value: Instance in ipairs(RootPart:GetDescendants()) do
    if value:IsA("Sound") then
        value:Destroy()
    end
end