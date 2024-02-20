local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local PlayerManager: PlayerManager = {}
PlayerManager.__index = PlayerManager

local ProfileService = require(ServerStorage:WaitForChild("ProfileService"))

local UpdateHud = ReplicatedStorage.Events.PlayerHud
local GameData = require(ServerStorage.GameData)

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
		Data: GameData.PlayerData,
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

	GiveGold: (number) -> number,
	GiveExperience: (number) -> number,
}

function PlayerManager.new(player: Player, options: Options)
	local self = setmetatable({
		Player = player,
		PlayerGui = player:WaitForChild("PlayerGui"),
		Character = player.Character or player.CharacterAdded:Wait(),
		CharacterAdded = player.CharacterAdded,
		Humanoid = player.Character:WaitForChild("Humanoid"),
		Profile = {},
		Options = options,
	}, PlayerManager)

	self.Humanoid.BreakJointsOnDeath = true

	function self:Newbie()
		BadgeService:AwardBadge(player.UserId, GameData.newbieBadge)
	end

	local Profile = ProfileStore:LoadProfileAsync(`Player_{player.UserId}`, "ForceLoad")
	if Profile then
		if player:IsDescendantOf(Players) then
			Profile:AddUserId(player.UserId)
			Profile:Reconcile()
			Profile:SetMetaTag("Version", game.PlaceVersion)
			local Joins = Profile:GetMetaTag("Joins") or 0
			Profile:SetMetaTag("Joins", Joins + 1)

			if Joins < 10 then
				self:Newbie()
			end

			if #Profile.Data.Inventory == 0 then
				Profile.Data.Inventory = GameData.defaultInventory
			end

			self.Profile = Profile
		else -- If the player leaves the game before the profile is loaded
			Profile:Release()
			return
		end
	else
		return player:Kick("[PlayerManager] Error while loading profile.")
	end

	function self:Set()
		local character = player.Character or player.CharacterAdded:Wait()
		repeat
			local Parts = character:GetDescendants()

			for _, part: BasePart in ipairs(Parts) do
				if not (part:IsA("BasePart")) then
					continue
				end

				part.CollisionGroup = "Players"
			end
			task.wait()
		until character.HumanoidRootPart.CollisionGroup == "Players" or character == nil
	end

	function self:GiveGold(number: number)
		if not Profile then
			return
		end
		Profile.Data.Gold += number

		return Profile.Data.Gold
	end

	function self:GiveExperience(number: number)
		if not Profile then
			return
		end

		Profile.Data.Experience = math.clamp(Profile.Data.Experience + number, 0, Profile.Data.Level * 243)
		UpdateHud:FireClient(player, "XP", Profile.Data.Experience)

		if Profile.Data.Experience == Profile.Data.Level * 243 then
			Profile.Data.Level += 1
			Profile.Data.Experience = 0

			UpdateHud:FireClient(player, "LevelUP", Profile.Data.Level)
		end

		return Profile.Data.Experience
	end

	self:Set()
	player.CharacterAdded:Connect(function(character)
		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")
		self:Set()
	end)

	function self:LoadCharacter()
		local humanoidDescription = Instance.new("HumanoidDescription")

		humanoidDescription.Shirt = 12244089619
		humanoidDescription.Pants = 12244095027

		humanoidDescription:SetAccessories({
			{
				Order = 1,
				AssetId = 12296044398,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Front,
			},
			{
				Order = 2,
				AssetId = 12296065618,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Hat,
			},

			{
				Order = 3,
				AssetId = 12296048589,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Waist,
			},
			{
				Order = 4,
				AssetId = 12296053142,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Shoulder,
			},
			{
				Order = 5,
				AssetId = 12296057334,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Back,
			},
			{
				Order = 6,
				AssetId = 12296061546,
				Puffiness = 0.5,
				AccessoryType = Enum.AccessoryType.Hat,
			},
		}, false)

		self.Player:LoadCharacterWithHumanoidDescription(humanoidDescription)
	end

	return self
end

return PlayerManager
