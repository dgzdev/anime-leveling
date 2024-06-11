local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local GoldService = Knit.CreateService {
    Name = "GoldService",
    Client = {
        GoldUpdated = Knit.CreateSignal()
    },
}

local PlayerService

function GoldService:UpdateGold(Player: Player, Amount: number?)
    GoldService.Client.GoldUpdated:Fire(Player, Amount or GoldService:GetGold(Player))
end

function GoldService:GetGold(Player)
    return PlayerService:GetData(Player).Gold
end

function GoldService:HaveGold(Player: Player, Amount: number): boolean
    local PlayerData = PlayerService:GetData(Player)
    return PlayerData.Gold >= Amount 
end

function GoldService:RemoveGold(Player: Player, Amount: number): number | boolean
    local PlayerData = PlayerService:GetData(Player)
    if not GoldService:HaveGold(Player, Amount) then
        return false
    end

    PlayerData.Gold -= Amount
    GoldService:UpdateGold(Player, PlayerData.Gold)
    return PlayerData.Gold
end

function GoldService:AddGold(Player: Player, Amount: number): number
    local PlayerData = PlayerService:GetData(Player)
    PlayerData.Gold += Amount
    GoldService:UpdateGold(Player, PlayerData.Gold)
    return PlayerData.Gold
end

function GoldService:SetGold(Player: Player, Amount: number)
    local PlayerData = PlayerService:GetData(Player)
    PlayerData.Gold = Amount
    GoldService:UpdateGold(Player, PlayerData.Gold)
end

-- caso for possivel comprar, executa o callback
function GoldService:Buy(Player: Player, Amount: number, callback)
    if GoldService:HaveGold(Player, Amount) then
        GoldService:RemoveGold(Player, Amount)
        callback(true)
    end
    
end



function GoldService.KnitInit()
    PlayerService = Knit.GetService("PlayerService")    
end

function GoldService.KnitStart()
    
end

return GoldService