local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Sword = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService
local CombatService
local PlayerService
local ProgressionService
local SkillService

local GameData = require(ServerStorage.GameData)

local function CalculateDamage(BaseDamage)
	local LocalStatus = ProgressionService.LocalStatus

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

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
end

local SwordHitFunction = function(
	Character: Model,
	hitted: Model,
	kb: number,
	vfx: string,
	sfx: string,
	dmg: number?,
	ragdoll: number?
)
	---eu vou fazer um calculo com o parametro de dano base
	--> infelizmente, ta tudo separado e cada tipo de arma tem uma funcao dessa
	--> o ideal seria q ele pegasse o dano base da arma q ele ta usando, somasse com os pontos gastos e multiplicasse pelo tipo de ataque
	-- ! ja venho

	local data = PlayerService:GetData(Character)
	if not data then
		return
	end

	local weapon = data.Equiped.Weapon
	local weaponData = GameData.gameWeapons[weapon]
	if not weaponData then
		return
	end

	dmg = dmg or 1

	local damage = CalculateDamage(weaponData.Damage * dmg)
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

Sword.Default = {
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
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "SwordHit", "SwordHit", nil, 0)
			end)
		end
	end,

	Defense = function(...)
		print("Defense")
	end,

	FlashStrike = function(...)
		local args = table.pack(...)
		local send = { "FlashStrike", args[1], args[2], args[3], SwordHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,
}

Sword.StarterSword = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Sword.Default.Attack(Character, InputState, p)
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
		Sword.Default.Defense(Character, InputState, p)
	end,
}

Sword.IronStarterSword = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Sword.Default.Attack(Character, InputState, p)
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
		Sword.Default.Defense(Character, InputState, p)
	end,

	FlashStrike = Sword.Default.FlashStrike,
}

Sword.LuxurySword = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Sword.Default.Attack(Character, InputState, p)
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
		Sword.Default.Defense(Character, InputState, p)
	end,

	FlashStrike = Sword.Default.FlashStrike,
}

Sword["Maou'sSword"] = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: { Position: CFrame, Combo: number, Combos: number }
	)
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace:FindFirstChild("Enemies") }

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "LightningSwordHit", "SwordHit", nil, 0)
			end)
		end
	end,

	Defense = function(...)
		Sword.Default.Defense(...)
	end,

	FlashStrike = function(...)
		local args = table.pack(...)
		local send = { "LightningFlashStrike", args[1], args[2], args[3], SwordHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,

	["Eletric Wave"] = function(...)
		SkillService:CallSkill("EletricWave", ...)
	end,

	Lightning = function(...)
		local args = table.pack(...)
		local send = { "Lightning", args[1], args[2], args[3], SwordHitFunction }

		SkillService:CallSkill(table.unpack(send))
	end,
}

Sword["Nyon"] = Sword.Default
Sword["Mister"] = Sword.Default

function Sword.Start(default)
	Default = default

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")
	SkillService = Knit.GetService("SkillService")

	HitboxService = Knit.GetService("HitboxService")

	ProgressionService = Knit.GetService("ProgressionService")
	CombatService = Knit.GetService("CombatService")

	PlayerService = Knit.GetService("PlayerService")
end

return Sword
