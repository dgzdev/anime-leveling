local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientEvent = ReplicatedStorage.Events:FindFirstChild("MainEvents") :: RemoteEvent


local Handler = {
    ["CheckLoot"] = function(Data)
        print(Data)
    end
}


ClientEvent.OnClientEvent:Connect(function(callbackName, Data)
    if Handler[callbackName] then
        Handler[callbackName](Data)
    end
end)





