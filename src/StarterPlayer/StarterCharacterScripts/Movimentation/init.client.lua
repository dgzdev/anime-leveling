local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
--// Main script of Movimentation system
--// @author: SinceVoid, DivinitySin

--// Local Variables
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ====================================================================================================
--// Modules
-- ====================================================================================================
local Sprint = require(script:WaitForChild("Sprint"))
local Dash = require(script:WaitForChild("Dash"))
local Jump = require(script:WaitForChild("Jump"))

-- ====================================================================================================
-- // ContextActionService
-- ====================================================================================================
local SprintKeys = {Enum.KeyCode.W}
local LastTap = 0 --// LastTime that the player pressed the key
ContextActionService:BindAction("Sprint", function(action, state, object)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

    if tick() - LastTap < 0.5 then
        Sprint.Start()
    end

    LastTap = tick()

    return Enum.ContextActionResult.Pass
end, false, table.unpack(SprintKeys))


local DashKeys = {Enum.KeyCode.Q}
local DashCooldown = 1.5
local LastDash = 0 --// LastTime that the player pressed the key
ContextActionService:BindAction("Dash", function(action, state, object)
    if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

    if (tick() - LastDash) > DashCooldown then
        Dash:Release({
            Direction = Dash.GetDirection(),
            Duration = Dash.Defaults.Duration,
            Speed = Dash.Defaults.Speed,
        })
        LastDash = tick()
    end

    return Enum.ContextActionResult.Pass
end, false, table.unpack(DashKeys))

-- ====================================================================================================
--// States
-- ====================================================================================================

-- Variables
-- Humanoid States
local function OnRunning(speed: number)
    --// Stop Sprinting
    if speed < 0.1 then
        Sprint.Disable()
    end
end

local function OnDie() end
local function OnSwimming() end
local function OnJump() end
local function OnFall() end
local function StateChanged(old, new)
end

-- ====================================================================================================
--// Connections
-- ====================================================================================================
Humanoid.Running:Connect(OnRunning)
Humanoid.Died:Once(OnDie)
Humanoid.Swimming:Connect(OnSwimming)
Humanoid.Jumping:Connect(OnJump)
Humanoid.StateChanged:Connect(StateChanged)