local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuildService = Knit.CreateService({
	Name = "GuildService",
	Client = {},
})
local ProfileService = require(ReplicatedStorage.Packages.profileservice)
local ProfileStore = ProfileService.GetProfileStore("Guilds - teste - 1", {})

function GuildService:CreateGuildId() end

function GuildService:KnitInit() end
function GuildService:KnitStart() end

return GuildService
