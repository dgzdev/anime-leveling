local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CharacterService = Knit.CreateService {
    Name = "CharacterService",
}

function CharacterService:UpdateWalkSpeed(Humanoid: Humanoid, overwrite: string, newWalkspeed: number?)
    local newWalkspeed = newWalkspeed or 12-- pega o walkspeed de walk

end

return CharacterService