local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Events = {}

-- ====================================================================================================
--// Modules
-- ====================================================================================================
local ProfileService = require(script.Parent.ProfileService)

-- ====================================================================================================
-- // Data
-- ====================================================================================================
local Bindables = require(ServerScriptService.Data.Bindables)
local Useful = require(ServerScriptService.Data.Useful)

-- ====================================================================================================
--// Profile
-- ====================================================================================================
local ProfileTemplate = Useful.ProfileTemplate
local ProfileStore = ProfileService.GetProfileStore(Useful.ProfileKey, ProfileTemplate)

local Profiles = require(ReplicatedStorage.Profiles)
local Storage = {}

-- ====================================================================================================
--// Events
-- ====================================================================================================

local CONNECT = {
    [Players] = {
        PlayerAdded = Players.PlayerAdded:Connect(function(player: Player)
            local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
            if profile ~= nil then
                profile:AddUserId(player.UserId) -- GDPR compliance
                profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
                profile:ListenToRelease(function()
                    Storage[player] = nil
                    Profiles[player] = nil
                    player:Kick()
                end)
                if player:IsDescendantOf(Players) == true then
                    Storage[player] = profile
                    Profiles[player] = profile.Data
                    Bindables.Profile_Load:Fire(player, profile.Data)
                else
                    profile:Release()
                end
            else
                player:Kick()
            end

        end),
        PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
            Profiles[Player] = nil
            if Storage[Player] ~= nil then
                Storage[Player]:Release()
            end
        end),
    },
}

return Events