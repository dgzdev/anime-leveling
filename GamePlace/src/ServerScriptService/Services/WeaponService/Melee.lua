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

local GameData = require(ServerStorage.GameData)

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

		Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * kb) * GetModelMass(hitted)
		local rag = ragdoll or 2

		HitboxService:CreateStun(hitted, 0.75, function()
			if rag > 0 then
				ApplyRagdoll(hitted, rag)
			end
		end)

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
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		HitboxService:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 25, function(hitted: Model)
			MeleeHitFunction(Character, hitted, 5, "CombatHit", "Melee", nil, 0)
		end, op)
	end,

	Defense = function(...)
		Default.Defense(...)
	end,

	["Strong Punch"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		--[[
			function HitboxService:CreatePartHitbox(Character: Model, HitboxSize: Vector3, Ticks: number, callback: any)

			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
				if Humanoid then
					if Humanoid:GetAttribute("Died") then
						return
					end
					if (Humanoid.Health - damage) <= 0 then
						Humanoid:SetAttribute("Died", true)
						CombatService:RegisterHumanoidKilled(Character, Humanoid)
					end
					Humanoid:TakeDamage(damage)
				end

		]]

		HitboxService:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 25, function(hitted)
			MeleeHitFunction(Character, hitted, 30, "CombatHit", "Melee", nil, 2)
		end, op)
	end,
	["Ground Slam"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		HitboxService:CreatePartHitbox(Character, Vector3.new(25, 5, 25), 35, function(hitted)
			MeleeHitFunction(Character, hitted, 30, "CombatHit", "Melee", nil, 2)
		end, op)

		RenderService:RenderForPlayersInArea(p.Position.Position, 100, {
			["module"] = "Melee",
			["effect"] = "GroundSlam",
			root = Character.PrimaryPart,
		})
	end,
}

-- item melee
Melee.Melee = {
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

Melee.Melee2 = {
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

function Melee.Start(default)
	default = default

	HitboxService = Knit.GetService("HitboxService")
	HitboxService = Knit.GetService("HitboxService")
	RenderService = Knit.GetService("RenderService")
	CombatService = Knit.GetService("CombatService")
	RagdollService = Knit.GetService("RagdollService")
	ProgressionService = Knit.GetService("ProgressionService")
	PlayerService = Knit.GetService("PlayerService")
end

return Melee
