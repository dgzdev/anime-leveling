local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Local Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Root = Character:WaitForChild("HumanoidRootPart")
local Legs = Root:WaitForChild("Legs")
local LeftFoot = Character:WaitForChild("LeftFoot")
local RightFoot = Character:WaitForChild("RightFoot")

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

    local Start = Legs:WaitForChild("Start")
    local RunningParticles1 = LeftFoot:WaitForChild("SmokeRunning"):GetChildren()
    local RunningParticles2 = RightFoot:WaitForChild("SmokeRunning"):GetChildren()

    local SprintFX = ReplicatedStorage:WaitForChild("FX"):WaitForChild("Sprint"):WaitForChild("Wind"):Clone()

    SprintFX.Parent = Workspace:WaitForChild("Effects")
    SprintFX:PivotTo(Root.CFrame * CFrame.new(0,0,2))
    SprintFX.Name = "Sprint_"..Player.Name

    local Weld = Instance.new("WeldConstraint", SprintFX)
    Weld.Part0 = Root
    Weld.Part1 = SprintFX

    local Particles = Start:GetChildren()

    TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(0.4), {FieldOfView = 90}):Play()
    Humanoid.WalkSpeed = SprintSpeed

    for _, Particle in ipairs(Particles) do
        Particle:Emit(Particle:GetAttribute("EmitCount"))
    end
    for _, Particle in ipairs(RunningParticles1) do
        Particle.Enabled = true
    end
    for _, Particle in ipairs(RunningParticles2) do
        Particle.Enabled = true
    end

    --// Animations
    --// TODO: Change animations
    
    SprintModule.Enabled = true --// This is the last thing to do, so we can check if the player is sprinting or not
end

function SprintModule.Disable() --// Começa a andar
    --// Change Camera FOV
    --// Change WalkSpeed
    --// Change Animations

    local End = Legs:WaitForChild("End"):GetChildren()
    local RunningParticles1 = LeftFoot:WaitForChild("SmokeRunning"):GetChildren()
    local RunningParticles2 = RightFoot:WaitForChild("SmokeRunning"):GetChildren()

    local FX = Workspace:WaitForChild("Effects"):FindFirstChild("Sprint_"..Player.Name)
    if FX then
        FX:Destroy()
    end

    for _, Particle in ipairs(RunningParticles1) do
        Particle.Enabled = false
    end
    for _, Particle in ipairs(RunningParticles2) do
        Particle.Enabled = false
    end
    for _, Particle in ipairs(End) do
        Particle:Emit(Particle:GetAttribute("EmitCount"))
    end
    TweenService:Create(Workspace.CurrentCamera, TweenInfo.new(0.8), {FieldOfView = 70}):Play()
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