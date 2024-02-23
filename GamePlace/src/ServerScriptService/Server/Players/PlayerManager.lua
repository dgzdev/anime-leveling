local BadgeService = game:GetService("BadgeService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
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
	PlayerGui: PlayerGui,
	Character: Model,
	CharacterAdded: RBXScriptSignal,
	Humanoid: Humanoid,
	Profile: {},
	Options: Options,
}

function PlayerManager.new(player: Player, options: Options)
	local self = setmetatable({
		Player = player,
		PlayerGui = player:WaitForChild("PlayerGui"),
		Character = nil,
		CharacterAdded = player.CharacterAdded,
		Humanoid = nil,
		Profile = {},
		Options = options,
	}, PlayerManager)

	self:LoadProfile()

	self.Player:LoadCharacter()
	self:OnCharacterReceive(player.Character or player.CharacterAdded:Wait())

	player.CharacterAdded:Connect(function(character)
		self:OnCharacterReceive(character)
	end)

	return self
end

function PlayerManager:OnCharacterReceive(character: Model)
	self.Character = character
	self.Humanoid = character:WaitForChild("Humanoid")

	self.Character:AddTag("PlayerCharacter")

	for _, b: BasePart in ipairs(self.Character:GetDescendants()) do
		if not b:IsA("BasePart") then
			continue
		end

		b.CollisionGroup = "Players"
	end
end

function PlayerManager:LoadCharacter()
	return self.Player:LoadCharacter()
end

function PlayerManager:Newbie()
	return BadgeService:AwardBadge(self.Player.UserId, GameData.newbieBadge)
end

function PlayerManager:GiveGold(number: number)
	if not self.Profile then
		return
	end
	self.Profile.Data.Gold += number

	return self.Profile.Data.Gold
end

function PlayerManager:GiveExperience(number: number)
	if not self.Profile then
		return
	end

	self.Profile.Data.Experience = math.clamp(self.Profile.Data.Experience + number, 0, self.Profile.Data.Level * 243)
	UpdateHud:FireClient(self.Player, "XP", self.Profile.Data.Experience)

	if self.Profile.Data.Experience == self.Profile.Data.Level * 243 then
		self.Profile.Data.Level += 1
		self.Profile.Data.Experience = 0

		UpdateHud:FireClient(self.Player, "LevelUP", self.Profile.Data.Level)
	end

	return self.Profile.Data.Experience
end

function PlayerManager:LoadProfile()
	if RunService:IsStudio() then
		local profile = { Data = GameData.profileTemplate }
		profile.Data.Inventory = GameData.defaultInventory

		self.Profile = profile
		return self.Profile
	else
		local Profile = ProfileStore:LoadProfileAsync(`Player_{self.Player.UserId}`, "ForceLoad")
		if Profile then
			if self.Player:IsDescendantOf(Players) then
				Profile:AddUserId(self.Player.UserId)
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
				return self.Profile
			else -- If the player leaves the game before the profile is loaded
				Profile:Release()
				return
			end
		else
			return self.Player:Kick("[PlayerManager] Error while loading profile.")
		end
	end
end

return PlayerManager
