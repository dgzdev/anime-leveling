local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Melee = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Default

local HitboxService
local RagdollService
local RenderService
local CombatService
local ProgressionService
local PlayerService
local WeaponService
local SkillService
local EnemyService

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

local function ApplyRagdoll(model: Model, time: number)
	RagdollService:Ragdoll(model, time)
end

local BlockAnimation

local MeleeHitFunction = function(
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

	if hitted:GetAttribute("Defense") == true then
		RenderService:RenderForPlayersInArea(hitted.PrimaryPart.CFrame.Position, 200, {
			module = "Universal",
			effect = "Replicate",
			root = hitted.PrimaryPart,
			["VFX"] = "BlockedHit",
			["SFX"] = "Block",
		})
		return
	end
	print(dmg)
	dmg = dmg or 1
	local damage
	if not Players:GetPlayerFromCharacter(Character) then
		damage = dmg
	else
		damage = CalculateDamage(weaponData.Damage * dmg, Player) or 10
	end
	--print(damage)
	local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
	if Humanoid then
		if Humanoid:GetAttribute("Died") then
			return
		end

		if (Humanoid.Health - damage) <= 0 then
			Humanoid:SetAttribute("Died", true)
			CombatService:RegisterHumanoidKilled(Character, Humanoid)
		end

		RenderService:RenderForPlayersInArea(hitted.PrimaryPart.CFrame.Position, 200, {
			module = "Universal",
			effect = "Replicate",
			root = hitted.PrimaryPart,
			["VFX"] = vfx,
			["SFX"] = sfx,
		})

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

Melee.Default = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local op = WeaponService:GetOverlapParams(Character)

		HitboxService:CreateHitbox(Character, Vector3.new(2, 5, 2), 25, function(hitted: Model)
			if not Players:GetPlayerFromCharacter(Character) then
				if Character:GetAttribute("Damage") then
					MeleeHitFunction(Character, hitted, 0, "CombatHit", "Melee", Character:GetAttribute("Damage"), 0)
					return
				end
			end
			MeleeHitFunction(Character, hitted, 0, "CombatHit", "Melee", nil, 0)
		end, op)
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
		Default.Defense(Character, InputState, p)
	end,

	["Strong Punch"] = function(...)
		local args = table.pack(...)
		local send = { "Strong Punch", args[1], args[2], args[3], MeleeHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["Ground Slam"] = function(...)
		local args = table.pack(...)
		local send = { "GroundSlam", args[1], args[2], args[3], MeleeHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,
}

-- item melee
Melee.Fists = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Melee.Default.Attack(Character, InputState, p)
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
		Melee.Default.Defense(Character, InputState, p)
	end,

	["Strong Punch"] = Melee.Default["Strong Punch"],
	["Ground Slam"] = Melee.Default["Ground Slam"],
}

Melee["GoldenGauntlets"] = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local op = WeaponService:GetOverlapParams(Character)

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in (WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 10, function(hitted: Model)
				MeleeHitFunction(Character, hitted, 5, "CombatHit", "Melee", nil, 0)
			end, op)
		end
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
		Melee.Default.Defense(Character, InputState, p)
	end,

	["Strong Punch"] = Melee.Default["Strong Punch"],
	["Ground Slam"] = Melee.Default["Ground Slam"],
}

Melee.Omnitrix = Melee.Default

function Melee.Start(default)
	Default = default

	SkillService = Knit.GetService("SkillService")
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	RenderService = Knit.GetService("RenderService")
	CombatService = Knit.GetService("CombatService")
	RagdollService = Knit.GetService("RagdollService")
	ProgressionService = Knit.GetService("ProgressionService")
	PlayerService = Knit.GetService("PlayerService")
	EnemyService = Knit.GetService("EnemyService")
end

return Melee
