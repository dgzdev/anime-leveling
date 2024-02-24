local PartyService = {}

local Players = game:GetService("Players")

local Parties = {}

export type Party = {
	Leader: number,
	Members: { [number]: number },
	InvitedTo: { [number]: number },
}

local PARTY_LIMIT = 4

--// Retorna a party do player usando como parâmetro o UserId
function PartyService:GetPartyByUserId(UserId: number): Party
	for _, party in pairs(Parties) do
		for _, member in pairs(party.Members) do
			if member.UserId == UserId then
				return party
			end
		end
	end
end

--// Retorna a party do player usando como parâmetro o Player
function PartyService:GetPartyByPlayer(Player: Player): Party
	return PartyService:GetPartyByUserId(Player)
end

--// Retorna a party que player foi invitado usando como parâmetro o UserId
function PartyService:GetPartyInvitedFromUserId(UserId: number): Party
	for _, party in pairs(Parties) do
		for _, member in pairs(party.InvitedTo) do
			if member.UserId == UserId then
				return party
			end
		end
	end
end

--// Retorna a party que player foi invitado usando como parâmetro o Player
function PartyService:GetPartyInvitedFromPlayer(Player: Player): Party
	return PartyService:GetPartyInvitedFromUserId(Player.UserId)
end

--// Cria uma party nova e adiciona na table de Parties
function PartyService:CreateParty(Player: Player): string
	if PartyService:GetPartyByPlayer(Player) then
		return "Player is already in a party"
	end

	local Party: Party = {
		Leader = Player.UserId,
		Members = { Player.UserId },
		InvitedTo = {},
	}
	table.insert(Parties, Party)
	return "Party created"
end

function PartyService:InviteToParty(Leader: Player, PlayerToInviteId: number): string
	if PartyService:GetPartyByUserId(PlayerToInviteId) then
		return "Player invited is already in a party"
	end

	--// Cria uma party caso necessário
	PartyService:CreateParty(Leader)

	local Party = PartyService:GetPartyByPlayer(Leader)

	if #Party.Members >= PARTY_LIMIT then
		return "Party is full"
	end

	local PartyInvitedFrom = PartyService:GetPartyInvitedFromUserId(PlayerToInviteId)
	if PartyInvitedFrom then
		if PartyInvitedFrom == Party then
			return "Player is already invited"
		end

		return "Player is already invited from another party"
	end

	table.insert(Party.InvitedTo, PlayerToInviteId)
	return "Invited player"
end

--// Retorna a table de Parties
function PartyService:GetParties(): { number: Party }
	return Parties
end

function PartyService:AcceptInvite(Player: Player): string
	local PartyInvitedFrom = PartyService:GetPartyInvitedFrom(Player)

	if not PartyInvitedFrom then
		return "Player is not invited from any party"
	end

	for index, userId in pairs(PartyInvitedFrom.InvitedTo) do
		if Player.UserId == userId then
			table.remove(PartyInvitedFrom.InvitedTo, index)
		end
	end

	if #PartyInvitedFrom.Members >= PARTY_LIMIT then
		return "Party is full"
	end

	table.insert(PartyInvitedFrom.Members, Player.UserId)
	return "Player joined the party"
end

function PartyService:DeclineInvite(Player: Player): string
	local PartyInvitedFrom = PartyService:GetPartyInvitedFrom(Player)

	if not PartyInvitedFrom then
		return "Player is not invited from any party"
	end

	for index, userId in pairs(PartyInvitedFrom.InvitedTo) do
		if Player.UserId == userId then
			table.remove(PartyInvitedFrom.InvitedTo, index)
		end
	end
end

function PartyService:RemovePlayerFromParty(Leader: Player, PlayerToRemoveId: number): string
	local Party = PartyService:GetPartyByPlayer(Leader)

	if Leader.UserId == PlayerToRemoveId then
		return "You can't remove yourself"
	end

	if not Party then
		return "You are not in a party"
	end

	if Party.Leader ~= Leader.UserId then
		return "You are not the leader"
	end

	if not table.find(Party.Members, PlayerToRemoveId) then
		return "Player is not in the same party"
	end

	table.remove(Party.Members, PlayerToRemoveId)
end

function PartyService:RemoveParty(Party: Party): boolean
	for index, party in pairs(Parties) do
		if party == Party then
			table.remove(Parties, index)
			return true
		end
	end

	return false
end

function PartyService:LeaveParty(Player: Player): string
	local Party = PartyService:GetPartyByPlayer(Player)

	if not Party then
		return "You are not in a party"
	end

	table.remove(Party.Members, Player.UserId)

	--// escolhe um novo lider
	if Party.Leader == Player.UserId then
		if #Party.Members >= 1 then
			local SelectedMember = Party.Members[math.random(1, #Party.Members)]
			Party.Leader = SelectedMember
		end
	end

	if #Party.Members <= 0 then
		PartyService:RemoveParty(Party)
	end

	return "Player left the party"
end

function PartyService:IsPlayersInTheSameParty(FirstPlayer: Player, SecondPlayer: Player): boolean
	local Party = PartyService:GetPartyByPlayer(FirstPlayer)
	if table.find(Party.Members, SecondPlayer.UserId) then
		return true
	end

	return false
end

function PartyService:IsCharactersInTheSameParty(FirstCharacter: Model, SecondCharacter: Model): boolean
	local FirstPlayer = Players:GetPlayerFromCharacter(FirstCharacter)
	if not FirstPlayer then
		return false
	end

	local SecondPlayer = Players:GetPlayerFromCharacter(SecondCharacter)
	if not SecondCharacter then
		return false
	end

	return PartyService:IsPlayersInTheSameParty(FirstPlayer, SecondPlayer)
end

return PartyService
