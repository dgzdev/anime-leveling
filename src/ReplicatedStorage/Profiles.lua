--[[
    Esse é o armazenamento de perfis do servidor, onde os dados dos jogadores serão armazenados.
    Você pode pegar o perfil de um jogador requirindo o módulo, exemplo:

    local Profiles = require(game:GetService("ReplicatedStorage").Profiles)
    local Profile = Profiles[Player]
    -> Profile será o perfil do jogador.
]]
local Profiles = {}
return Profiles