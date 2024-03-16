local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local DataStoreService = game:GetService("DataStoreService")

local GuildService = Knit.CreateService({
	Name = "GuildService",
	Client = {},
})

local PlayerService
local GuildDataStores = DataStoreService:GetDataStore("Guilds - teste - 1")

local GuildsCache = {}

function GuildService:GetGuildData(GuildName: string)
	if GuildsCache[GuildName] then
		return GuildsCache[GuildName]
	end

	GuildsCache[GuildName] = GuildDataStores:GetAsync(GuildName)
end

type MemberData = {
	Role: string,
}

type GuildType = {
	Name: string,
	Icon: string?,
	Members: { [number]: number },
}

function GuildService:GetPlayerGuild(Player: Player): string?
	local PlayerData = PlayerService:GetWholeData(Player)
	return PlayerData.Guild
end

function GuildService:GetGuild(GuildId: string): string? end

function GuildService:CheckValidName(text: string, fromPlayerId: number)
	local success, errorMessage = pcall(function()
		return TextService:FilterStringAsync(text, fromPlayerId)
	end)

	return success
end

function GuildService:CreateGuild(Player: Player, GuildName: string, GuildIcon: string?): string
	if not GuildService:CheckValidName(GuildName, Player.UserId) then
		return "Invalid name"
	end

	if GuildService:GetGuildData(GuildName) then
		return "Same name"
	end

	local Member: MemberData = {
		Role = "Owner",
	}

	local Guild: GuildType = {
		Name = GuildName,
		Members = {},
		Icon = GuildIcon,
	}

	return "Guild created"
end

function GuildService:KnitInit()
	PlayerService = Knit.GetService("PlayerService")
end
function GuildService:KnitStart() end

return GuildService
