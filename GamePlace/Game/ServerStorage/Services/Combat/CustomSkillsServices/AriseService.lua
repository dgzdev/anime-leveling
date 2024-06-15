local Knit = require(game.ReplicatedStorage.Packages.Knit)

local AriseService = Knit.CreateService({
	Name = "AriseService",
})

local DebounceService

AriseService.Handler = {}

function AriseService:SetPossessionMode(TargetHumanoid, Player)
    if not AriseService[Player.Name] then
        AriseService[Player.Name] = {}
        table.insert(AriseService[Player.Name], TargetHumanoid)
        local Index = #AriseService[Player.Name]

        task.delay(10, function()
            table.remove(AriseService[Player.Name], Index)
        end)
    end
end

function AriseService:GetPossessionAvailable(Player)
    if AriseService[Player.Name] then
        return AriseService[Player.Name]
    end
end

function AriseService:RemovePossession(Player, Humanoid)
    if AriseService[Player.Name] then
        for i,v in pairs(AriseService[Player.Name]) do
            if v == Humanoid then
                table.remove(AriseService[Player.Name], i)
            end
        end
    end
end

function AriseService:KnitStart()
    DebounceService = Knit.GetService("DebounceService")
end


return AriseService