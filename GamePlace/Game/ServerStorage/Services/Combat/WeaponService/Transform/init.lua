local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Dagger = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService
local PlayerService
local ProgressionService
local CombatService
local SkillService

local function ApplyRagdoll(model: Model, time: number)
	RagdollService:Ragdoll(model, time)
end

local GameData = require(ServerStorage.GameData)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
end

local function CalculateDamage(BaseDamage, Player)
	if not Player then
		return 10
	end
	local LocalStatus = ProgressionService.LocalStatus[Player.Name]

	if not BaseDamage then
		return
	end

	if not LocalStatus.Strength then
		warn("Couldn't find any local status with this name")
		return
	end
	return math.floor(math.sqrt((10 * BaseDamage) * ((LocalStatus.Strength + 1) * 0.3)))
end

local DaggerHitFunction = function(
	Character: Model,
	hitted: Model,
	kb: number,
	vfx: string,
	sfx: string,
	dmg: number?,
	ragdoll: number?
)
	local data = PlayerService:GetData(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not data then
		return
	end

	local weapon = data.Equiped.Weapon
	local weaponData = GameData.gameWeapons[weapon]
	if not weaponData then
		return
	end

	dmg = dmg or 1

	local damage = CalculateDamage(weaponData.Damage * dmg, Player) or 10
	local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
	if Humanoid then
		if Humanoid:GetAttribute("Died") then
			return
		end

		if (Humanoid.Health - damage) <= 0 then
			Humanoid:SetAttribute("Died", true)
			CombatService:RegisterHumanoidKilled(Character, Humanoid)
		end

		RenderService:RenderForPlayersInRadius({
			module = "Universal",
			effect = "Replicate",
			root = hitted.PrimaryPart,
			["VFX"] = vfx,
			["SFX"] = sfx,
		}, hitted.PrimaryPart.CFrame.Position, 200)

		local rag = ragdoll or 2

		kb = kb or 0

		if kb == 0 then
			HitboxService:CreateStun(hitted, 0.75, function()
				if rag > 0 then
					ApplyRagdoll(hitted, rag)
				end
			end)
		else
			Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * kb)
				* GetModelMass(hitted)
			if rag > 0 then
				ApplyRagdoll(hitted, rag)
			end
		end

		Humanoid:TakeDamage(damage)
		return false
	end
end

Dagger.Default = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace.Enemies }

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in (WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", nil, 0)
			end)
		end
	end,

	Defense = function(...)
		print("Defense")
	end,
}

Dagger["Venom'sFangs"] = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Dagger.Default.Attack(Character, InputState, p)
	end,

	Defense = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Dagger.Default.Defense(Character, InputState, p)
	end,

	["Venom Palm"] = function(...)
		local args = table.pack(...)
		local send = { "VenomPalm", args[1], args[2], args[3], DaggerHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["LStrike"] = function(...)
		local args = table.pack(...)
		local send = { "LStrike", args[1], args[2], args[3], DaggerHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["VenomBarrage"] = function(...)
		local args = table.pack(...)
		local send = { "VenomBarrage", args[1], args[2], args[3], DaggerHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["VenomDash"] = function(...)
		local args = table.pack(...)
		local send = { "VenomDash", args[1], args[2], args[3], DaggerHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["DualBarrage"] = function(...)
		local args = table.pack(...)
		local send = { "DualBarrage", args[1], args[2], args[3], DaggerHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,
}

Dagger.Dagger2 = Dagger.Default

function Dagger.Start(default)
	Default = default

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")
	SkillService = Knit.GetService("SkillService")

	HitboxService = Knit.GetService("HitboxService")
	HitboxService = Knit.GetService("HitboxService")

	CombatService = Knit.GetService("CombatService")
	ProgressionService = Knit.GetService("ProgressionService")
	PlayerService = Knit.GetService("PlayerService")
end

return Dagger
