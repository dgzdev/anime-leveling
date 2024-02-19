local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bindables = {
    ["InvokeServer"] = Instance.new("BindableFunction"),
    ["TriggerServer"] = Instance.new("BindableEvent"),

}

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Requester = Shared:WaitForChild("Requester")
local Events = Shared:WaitForChild("Events")

-- =======================================
-- // Type
-- =======================================

Bindables.InvokeServer.OnInvoke = function(data)
    return Requester:InvokeServer(table.unpack(data))
end
Bindables.TriggerServer.Event:Connect(function(data)
    Events:FireServer(table.unpack(data))
end)

return Bindables