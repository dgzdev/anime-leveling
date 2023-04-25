local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Interactions = {}

local Public = ReplicatedStorage:WaitForChild("Public")
local Useful = require(Public:WaitForChild("Useful"))

-- ======================================================================
-- // Type
-- ======================================================================
type Function = () -> ()

-- ======================================================================
-- // Auxiliar Functions
-- ======================================================================
local GetAtr = function(object: Instance, AttributeName: string)
    return object:GetAttribute(AttributeName)
end

local SetAtr = function(object: Instance, AttributeName: string, value: any)
    return object:SetAttribute(AttributeName,value)
end

local SetCooldown = function(Object: Instance, Time: number)
    local Enabled = Object["Enabled"]
    if Enabled == nil then
        return error("Object needs to be a Enabable.")
    end

    if typeof(Time) ~= "number" then
        return error("Time must be a valid number.")
    end

    Object.Enabled = false
    task.delay(Time, function()
        Object.Enabled = true
    end)
end

-- ======================================================================
-- // Metatable
-- ======================================================================
local Interaction = {}
Interaction.__index = Interaction

function Interaction.new(Object: Instance)
    local self = setmetatable(Interaction, {})

    local ProximityPrompt = Instance.new("ProximityPrompt", Object)
    self.Prompt = ProximityPrompt

    local Name = GetAtr(Object, "Name")
    local Action = GetAtr(Object, "Action")

    ProximityPrompt.ActionText = Action
    ProximityPrompt.ObjectText = Object.Name

    ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
    SetAtr(ProximityPrompt, "Theme", "Hide")

    self.DataSent = {
        "Interaction",
        {
            ProximityObject = ProximityPrompt,
            ObjectText = Object.Name,
            ActionText = Action,
        }
    }

    ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
        Useful.TriggerServer:Fire(self.DataSent)
        SetCooldown(ProximityPrompt, 2)
    end)
  
    return self
end

function Interaction:SetData(data: {})
    self.DataSent = data
end

-- ======================================================================
-- // Module
-- ======================================================================
function Interactions.Start(self, ...)
    for _, Object in ipairs(Workspace:GetDescendants()) do
        local Type = GetAtr(Object, "Type")
        if Type == "Interaction" then
            local Meta = Interaction.new(Object)
            
        end
    end


end

return Interactions