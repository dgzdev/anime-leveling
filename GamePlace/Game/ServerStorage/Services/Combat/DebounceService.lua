local Knit = require(game.ReplicatedStorage.Packages.Knit)

--[[
    Módulo responsável por adicionar debounces á um Humanoid.
    Os debounces podem ser "sobrepostos", removendo necessidade de utilizar instancias em pastas.
]]

local DebounceService = Knit.CreateService {
    Name = "DebounceService";
    Client = {}
}

local HumanoidDebounces = {}

--[[ adiciona um debounce no humanoid, pode apenas ser valores booleanos ]]
function DebounceService:AddDebounce(Humanoid: Humanoid, debounceName: string, time: number, setToAttribute: boolean?)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)

    if not debounceName then return print("Invalid debounce name") end
    if not time then return print("Invalid debounce timer") end
    if not Humanoid then return print("Humanoid is nil") end

    table.insert(Debounces, debounceName)
    if setToAttribute ~= false then
        Humanoid:SetAttribute(debounceName, true)
    end


    task.delay(time, function()
        local Index = table.find(Debounces, debounceName)

        table.remove(Debounces, Index)

        if not DebounceService:HaveDebounce(Humanoid, debounceName) then
            Humanoid:SetAttribute(debounceName, false)
        end
    end)
end

function DebounceService:HaveDebounce(Humanoid: Model, debounceName: string)
    local Index = DebounceService:GetIndex(Humanoid, debounceName)
    return Index ~= nil
end

function DebounceService:GetIndex(Humanoid: Model, debounceName: string)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)

    for i, v in Debounces do
        if v == debounceName then
            return i
        end
    end
end


function DebounceService:RemoveDebounce(Humanoid: Model, debounceName: string)
    local Debounces = DebounceService:GetHumanoidDebounces(Humanoid)

    local Index = DebounceService:GetIndex(Humanoid, debounceName)
    if Index then
        table.remove(Debounces, Index)
        Humanoid:SetAttribute(debounceName, nil)
    end
end

function DebounceService:RemoveHumanoidDebounces(Humanoid: Model)
    if HumanoidDebounces[Humanoid] then
        HumanoidDebounces[Humanoid] = nil
    end
end

function DebounceService:SetHumanoidDebounces(Humanoid: Model)
    if not HumanoidDebounces[Humanoid] then
        HumanoidDebounces[Humanoid] = {}
    end

    return HumanoidDebounces[Humanoid]
end

function DebounceService:GetHumanoidDebounces(Humanoid: Model)
    local Debounces = HumanoidDebounces[Humanoid]
    if not Debounces then
        Debounces = DebounceService:SetHumanoidDebounces(Humanoid)
    end

    return HumanoidDebounces[Humanoid]
end

return DebounceService