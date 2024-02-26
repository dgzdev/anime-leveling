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
local LoadCharacter = require(script.Parent:WaitForChild("LoadCharacter"))
export type Options = {
	[string]: any,
}
export type PlayerManager = {
	Player: Player,
	PlayerGui: PlayerGui,
	Character: Model,
	CharacterAdded: RBXScriptSignal,
	Humanoid: Humanoid,
	Profile: {
		["Slots"]: {
			["string"]: {
				["Character"]: {
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
				},
				["Location"]: string | "Character Creation",
				["LastJoin"]: string,
			} | "false",
		},
		["Selected_Slot"]: "1",
	},
	Options: Options,
	GetCurrentSlot: (
	) -> {
		["Character"]: {
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
		},
		["Location"]: string | "Character Creation",
		["LastJoin"]: string,
		["Data"]: {
			["Level"]: number,
			["Experience"]: number,
			["Gold"]: number,
			["Equiped"]: {
				["Weapon"]: string,
				["Id"]: number,
			},
			["Hotbar"]: { number },
			["Inventory"]: {
				[string]: {
					["AchiveDate"]: number,
					["Rank"]: GameData.Rank,
					["SubRank"]: GameData.SubRank,
					["Id"]: number,
				},
			},
			["Skills"]: { [string]: {
				["AchiveDate"]: number | nil,
				["Level"]: number,
			} },
			["Points"]: {
				["Inteligence"]: number,
				["Strength"]: number,
				["Agility"]: number,
				["Endurance"]: number,
			},
		},
	},
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
	self.Profile.Data = GameData.profileTemplate

	local Slot = self:GetCurrentSlot()
	self.Slot = Slot

	Slot.Location = "World 1"

	self.Player:LoadCharacter()
	self:OnCharacterReceive(player.Character or player.CharacterAdded:Wait())

	player.CharacterAdded:Connect(function(character)
		self:OnCharacterReceive(character)
	end)

	return self
end

function PlayerManager:GetCurrentSlot()
	return self.Profile.Data.Slots[self.Profile.Data.Selected_Slot]
end

function PlayerManager:OnCharacterReceive(character: Model)
	self.Character = character
	self.Humanoid = character:WaitForChild("Humanoid")

	task.wait()

	LoadCharacter:FromData(self.Player, self.Slot.Character)

	local lastHit = 0
	character:GetAttributeChangedSignal("Defending"):Connect(function()
		local atr = character:GetAttribute("Defending")
		if atr then
			if tick() - lastHit > 5 then
				character:SetAttribute("DefenseHits", 0)
			end
		end
	end)

	local lastDefenseHits = 0
	character:GetAttributeChangedSignal("DefenseHits"):Connect(function()
		local hits = character:GetAttribute("DefenseHits")
		if hits > lastDefenseHits then
			lastHit = tick()
		end
		lastDefenseHits = hits
	end)

	character:GetAttributeChangedSignal("Stun"):Connect(function()
		local isStunned = character:GetAttribute("Stun")
		if isStunned then
			self.Humanoid.WalkSpeed = 0
			self.Humanoid.JumpPower = 0

			task.wait(3)

			self.Humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
			self.Humanoid.JumpPower = StarterPlayer.CharacterJumpPower

			character:SetAttribute("Stun", false)
			character:SetAttribute("Defending", false)
			character:SetAttribute("Attacking", false)
			character:SetAttribute("DefenseHits", 0)
		else
			self.Humanoid.WalkSpeed = 16
			self.Humanoid.JumpPower = 50
		end
	end)

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

function PlayerManager:LoadProfile()
	local Profile = ProfileStore:LoadProfileAsync(tostring(self.Player.UserId), "ForceLoad")
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

return PlayerManager
