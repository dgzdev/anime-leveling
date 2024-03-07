local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Dagger = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService
local Hitbox2Service
local CombatService

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

local DaggerHitFunction = function(
	Character: Model,
	hitted: Model,
	kb: number,
	vfx: string,
	sfx: string,
	dmg: number?,
	ragdoll: number?
)
	local damage = dmg or 5
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
		if rag > 0 then
			ApplyRagdoll(hitted, rag)
		end

		Hitbox2Service:CreateStun(hitted, 0.75)

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
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			Hitbox2Service:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", nil, 0)
			end)
		end
	end,

	Defense = function(...)
		print("Defense")
	end,
}

Dagger.TestDagger = {
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
}

function Dagger.Start(default)
	default = default

	Knit.OnStart()

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")

	HitboxService = Knit.GetService("HitboxService")
	Hitbox2Service = Knit.GetService("Hitbox2Service")

	CombatService = Knit.GetService("CombatService")
end

return Dagger
