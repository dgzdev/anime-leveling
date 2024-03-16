local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local PlayerManager = {}
PlayerManager.__index = PlayerManager

local GameData = require(ServerStorage.GameData)
local ProfileService = require(ReplicatedStorage.Packages.profileservice)
local ProfileStore = ProfileService.GetProfileStore(GameData.profileKey, GameData.profileTemplate)

function PlayerManager.new(player: Player)
	local self = setmetatable({}, PlayerManager)

	player:LoadCharacter()
	self.Profile = {}

	self.Player = player

	self.Character = player.Character or player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.PlayerGui = player:WaitForChild("PlayerGui")

	local Animator = self.Humanoid:WaitForChild("Animator")

	task.spawn(function()
		while true do
			local Character = player.Character or player.CharacterAdded:Wait()
			if Character:GetAttribute("Stun") then
				task.wait(1)
				Character:SetAttribute("Stun", false)
			end
			Character:GetAttributeChangedSignal("Stun"):Wait()
		end
	end)

	local function CreatePlayerHealth()
		local PlayerHealth = game.ReplicatedStorage.Models.PlayerHealth:Clone()
		PlayerHealth.Parent = self.Character
		PlayerHealth.Adornee = self.Character:WaitForChild("Head")

		local Name = PlayerHealth:WaitForChild("Name"):WaitForChild("PlayerName")
		Name.Text = self.Character.Name

		local Health = PlayerHealth.Health.SizeFrame

		self.Humanoid.HealthChanged:Connect(function(health)
			local Scale = health / self.Humanoid.MaxHealth
			local Color = Color3.fromRGB(2, 255, 150):Lerp(Color3.new(1, 0, 0), 1 - Scale)
			local Tween = TweenService:Create(
				Health,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic),
				{ Size = UDim2.fromScale(Scale, 1), BackgroundColor3 = Color }
			)

			Tween:Play()
		end)
	end

	self.Player.CharacterAdded:Connect(function(character)
		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")

		CreatePlayerHealth()
	end)

	CreatePlayerHealth()

	return self
end

function PlayerManager:GetProfile()
	return self.Profile
end

function PlayerManager:Newbie()
	local newbieBadge = GameData.newbieBadge
	return BadgeService:AwardBadge(self.Player.UserId, newbieBadge)
end

function PlayerManager:GetData()
	local slot = self.Profile.Data["Selected_Slot"]
	local data: GameData.SlotData = self.Profile.Data["Slots"][slot].Data
	return data
end

function PlayerManager:GetPlayerSlot()
	local CurrentSlot = self.Profile.Data["Selected_Slot"]
	local Slot: GameData.PlayerSlot = self.Profile.Data["Slots"][CurrentSlot]
	return Slot
end

function PlayerManager:LoadProfile()
	local Profile = ProfileStore:LoadProfileAsync(`player_{self.Player.UserId}`, "ForceLoad")
	if Profile then
		Profile:Reconcile()

		--Profile.Data = GameData.profileTemplate

		self.Profile = Profile

		Profile:SetMetaTag("Version", game.PlaceVersion)
		local plays = Profile:GetMetaTag("Plays") or 0
		Profile:SetMetaTag("Plays", plays + 1)

		if plays <= 10 then
			self:Newbie()
		end

		return Profile
	else
		self.Player:Kick("Failed to load profile")
		return
	end
end

function PlayerManager:Release()
	self.Profile:Release()
end

export type Profile = {
	Data: GameData.ProfileData,
	GlobalUpdates: table,
	KeyInfo: any,
	KeyInfoUpdated: any,
	MetaData: any,
	MetaTagsUpdated: any,
	Reconcile: any,
	RobloxMetaData: table,
	UserIds: table,
	_hop_ready: boolean | false,
	_hop_ready_listeners: table,
	_is_user_mock: boolean,
	_load_timestamp: number,
	_profile_key: any,
	_profile_store: table,
	_release_listeners: any,
}
return PlayerManager
