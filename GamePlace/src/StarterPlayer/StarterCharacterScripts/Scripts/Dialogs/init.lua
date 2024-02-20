local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPC = require(script:WaitForChild("NPC"))

local Dialogs = {}

function Dialogs:Init()
    local NPCevent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("NPC")

    NPCevent.OnClientEvent:Connect(NPC.OnTrigger)
end

Dialogs.OnProfileReceive = function() return end

Dialogs:Init()
return Dialogs