local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Local Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local SprintModule = {}

--// Variables
local SprintSpeed = 24 --// This is the speed that the player will run
local WalkSpeed = 16 --// This is the speed that the player will walk
SprintModule.Enabled = false

function SprintModule.Start() --// Comeca a correr
    --// Change Camera FOV
    --// Change WalkSpeed
    --// Change Animations
    TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(0.5), {FieldOfView = 90}):Play()
    Humanoid.WalkSpeed = SprintSpeed

    --// Animations
    --// TODO: Change animations    
    
    SprintModule.Enabled = true --// This is the last thing to do, so we can check if the player is sprinting or not
end

function SprintModule.Disable() --// Começa a andar
    --// Change Camera FOV
    --// Change WalkSpeed
    --// Change Animations

    TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(0.5), {FieldOfView = 70}):Play()
    Humanoid.WalkSpeed = WalkSpeed
    
    --// Animations
    --// TODO: Change animations

    SprintModule.Enabled = false --// This is the last thing to do, so we can check if the player is sprinting or not
end

function SprintModule.Toggle(enabled: boolean)
    if enabled then
        SprintModule.Start()
    else
        SprintModule.Disable()
    end   
end

return SprintModule