local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

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

	self.Player.CharacterAdded:Connect(function(character)
		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")
	end)

	return self
end

function PlayerManager:GetProfile()
	return self.Profile
end

function PlayerManager:LoadCharacterAppearance(player: Player, data: CharacterData)
	task.wait()
	local character = player.Character or player.CharacterAdded:Wait()

	local Head = character:FindFirstChild("Head")
	local Torso = character:FindFirstChild("Torso")
	local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local RightArm = character:FindFirstChild("Right Arm")
	local LeftArm = character:FindFirstChild("Left Arm")
	local RightLeg = character:FindFirstChild("Right Leg")
	local LeftLeg = character:FindFirstChild("Left Leg")

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	local HumanoidDescription = Instance.new("HumanoidDescription")

	HumanoidDescription.BodyTypeScale = 1
	HumanoidDescription.HeadScale = 1

	for name, value in pairs(data) do
		if name == "Colors" then
			local Color = Color3.fromRGB(value[1], value[2], value[3])
			HumanoidDescription.HeadColor = Color
			HumanoidDescription.LeftArmColor = Color
			HumanoidDescription.RightArmColor = Color
			HumanoidDescription.LeftLegColor = Color
			HumanoidDescription.RightLegColor = Color
			HumanoidDescription.TorsoColor = Color
		else
			HumanoidDescription[name] = value
		end
	end
	task.wait()
	humanoid:ApplyDescription(HumanoidDescription, Enum.AssetTypeVerification.Default)
end

export type CharacterData = {
	["FaceAccessory"]: number,
	["HairAccessory"]: number,
	["BackAccessory"]: number,
	["WaistAccessory"]: number,
	["ShouldersAccessory"]: number,
	["NeckAccessory"]: number,
	["HatAccessory"]: number,
	["Shirt"]: number,
	["Pants"]: number,
	["Colors"]: { number },
}

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
		return error("Error while loading profile.")
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
