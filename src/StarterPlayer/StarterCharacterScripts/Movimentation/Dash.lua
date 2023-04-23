local Dash = {}

type DashOptions = {
    Direction: Vector3 | nil,
    Duration: number | nil,
    Speed: number | nil,
}

--// Default Dash Options
local DashOptions = {
    Direction = Vector3.new(0,0,-1),
    Duration = 0.1853,
    Speed = 150,
}

Dash.Defaults = {
    Direction = DashOptions.Direction,
    Duration = DashOptions.Duration,
    Speed = DashOptions.Speed,
}

--// Local Variables
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// Soltar o Dash
function Dash:Release(Options: DashOptions): BodyVelocity
    local Direction = (Options.Direction or DashOptions.Direction) * Vector3.new(1,0,1)
    local Duration = Options.Duration or DashOptions.Duration
    local Speed = Options.Speed or DashOptions.Speed

    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Direction * Speed
    BodyVelocity.Parent = Character.PrimaryPart

    Debris:AddItem(BodyVelocity, Duration)
    return BodyVelocity
end

function Dash:GetDirection(CharacterModel: Model | nil): Vector3
    local char = CharacterModel or Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    local MoveDirection = hum.MoveDirection
    if MoveDirection.Magnitude == 0 then
        MoveDirection = Vector3.new(0,0,-1)
    end

    return MoveDirection
end

return Dash