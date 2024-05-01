local Service = {}
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PartyHandler = {}

local PortalService = Knit.CreateService({
	Name = "PartieService",
	Client = {},
})

function Service:RemovePlayer(Player, Party)
	self:FindPlayerInParty(Player, Party, function()
		local Index = table.find(Party.Members, Player.Name)
		table.remove(Party.Members, Index)
	end)
end

function Service:FindPlayerInParty(Player, Party, callback)
	local Index = table.find(Party.Members, Player.Name)
	if Index then
		if callback then
			callback()
		end
		return Index
	end
end

function Service:AddPlayerToParty(Player, Party)
	if self:IsInParty(Player) then
		warn("Player Already in a Party!")
		return
	else
		table.insert(Party.Members, Player.Name)
	end
end

function Service:IsInParty(Player)
	for i, v in pairs(PartyHandler) do
		if table.find(v.Members, Player.Name) then
			warn("Player Already in a Party!")
			return
		end
	end
end

function Service:FindPartyByHost(HostName, callback)
	for i, v: Party in pairs(PartyHandler) do
		if v.Host == HostName then
			return v
		end
	end
end

function Service:CreateParty(Player)
	if self:IsInParty(Player) then
		return
	end

	table.insert(PartyHandler, {
		Members = { Player.Name },
		Host = Player.Name,
	})
end

function Service.KnitInit()
	PortalService:KnitInit()
end

type Party = {
	Members: { string },
	Host: string,
}

return Service
