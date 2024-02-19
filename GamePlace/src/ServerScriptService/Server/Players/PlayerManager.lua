local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PlayerManager = {}
PlayerManager.__index = PlayerManager

local ProfileService = require(ServerStorage:WaitForChild("ProfileService"))
local GameData = require(ServerStorage:WaitForChild("GameData"))

local ProfileStore = ProfileService.GetProfileStore(GameData.profileKey, GameData.profileTemplate)

export type Options = {
	[string]: any,
}
export type PlayerManager = {
	Player: Player,
	Character: Model,
	CharacterAdded: RBXScriptSignal,
	Humanoid: Humanoid,
	Profile: {
		AddUserId: (number) -> nil,
		Data: any,
		GlobalUpdates: table,
		KeyInfo: any,
		KeyInfoUpdated: any,
		MetaData: any,
		MetaTagsUpdated: any,
		Reconcile: any,
		RobloxMetaData: table,
		SetMetaTag: (string, any) -> nil,
		UserIds: table,
		_hop_ready: boolean | false,
		_hop_ready_listeners: table,
		_is_user_mock: boolean,
		_load_timestamp: number,
		_profile_key: any,
		_profile_store: table,
		_release_listeners: any,
	},
	Options: Options,
}

function PlayerManager.new(player: Player, options: Options): PlayerManager
	local self = setmetatable(PlayerManager, {
		Player = player,
		Character = player.Character or player.CharacterAdded:Wait(),
		CharacterAdded = player.CharacterAdded,
		Humanoid = player.Character:WaitForChild("Humanoid"),
		Profile = {},
		Options = options,
	})

	local Profile = ProfileStore:LoadProfileAsync(`Player_{player.UserId}`, "ForceLoad")
	if Profile then
		if player:IsDescendantOf(Players) then
			Profile:AddUserId(player.UserId)
			Profile:Reconcile()
			Profile:SetMetaTag("Version", game.PlaceVersion)

			self.Profile = Profile
		else -- If the player leaves the game before the profile is loaded
			Profile:Release()
			return
		end
	else
		return player:Kick("[PlayerManager] Error while loading profile.")
	end

	player.CharacterAdded:Connect(function(character)
		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")
	end)

	return self
end

return PlayerManager
