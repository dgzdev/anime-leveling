local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

--[[
    Módulo responsável por adicionar debounces á um Humanoid.
    Os debounces podem ser "sobrepostos", removendo necessidade de utilizar instancias em pastas.
]]

local DebounceService = Knit.CreateService {
    Name = "DebounceService";
    Client = {
        DebounceAdded = Knit.CreateSignal(),
        -- DebounceRemoved = Knit.CreateSignal(),
    }
}

local HumanoidDebounces = {}

--[[ adiciona um debounce no humanoid, pode apenas ser valores booleanos ]]
function DebounceService:AddDebounce(Humanoid: Humanoid, debounceName: string, Duration: number, showDebounce: boolean?, setToAttribute: boolean?)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)

    if not debounceName then return print("Invalid debounce name") end
    if not Duration then return print("Invalid debounce timer") end
    if not Humanoid then return print("Humanoid is nil") end

    table.insert(Debounces, debounceName)
    if setToAttribute ~= false then
        Humanoid:SetAttribute(debounceName, true)
    end

    task.delay(Duration, function()
        local Index = table.find(Debounces, debounceName)
        if Index then
            table.remove(Debounces, Index)
            if not DebounceService:HaveDebounce(Humanoid, debounceName) then
                Humanoid:SetAttribute(debounceName, nil)
            end
        end
    end)

    if not showDebounce then
        return
    end

    local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)

    if Player then
        local DebounceData = {
            Name = debounceName,
            Duration = Duration,
        }

        DebounceService.Client.DebounceAdded:Fire(Player, DebounceData)
    end
end

function DebounceService:HaveDebounce(Humanoid: Model, debounceName: string)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)
    return table.find(Debounces, debounceName) ~= nil
end

function DebounceService:RemoveDebounce(Humanoid: Model, debounceName: string)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)

    local Index = table.find(Debounces, debounceName)
    if Index then
        table.remove(Debounces, Index)
        if not DebounceService:HaveDebounce(Humanoid, debounceName) then
            Humanoid:SetAttribute(debounceName, nil)
        end
    end
end

function DebounceService:RemoveHumanoidDebounces(Humanoid: Model)
    if HumanoidDebounces[Humanoid] then
        HumanoidDebounces[Humanoid] = nil
    end
end

function DebounceService:SetHumanoidDebounces(Humanoid: Model)
    HumanoidDebounces[Humanoid] = {}
    warn("Set new")
end

function DebounceService:GetHumanoidDebounces(Humanoid: Model)
    local Debounces = HumanoidDebounces[Humanoid]
    if not Debounces then
        DebounceService:SetHumanoidDebounces(Humanoid)
    end

    return HumanoidDebounces[Humanoid]
end

return DebounceService