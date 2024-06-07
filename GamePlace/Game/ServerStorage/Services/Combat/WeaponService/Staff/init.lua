local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Staff = {}

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

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

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

local StaffHitFunction = function(
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
	local Player = game.Players:GetPlayerFromCharacter(Character)
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

Staff.Default = {
	LSpell = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,

			Mouse: Vector3,
			From: CFrame,

			Combo: number,
			Combos: number,
		}
	)
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace.Enemies }

		local Skill = ReplicatedStorage.Essentials.Mages.BlueSkil:Clone()
		Skill:PivotTo(p.From)
		local PrimaryPart = Skill.PrimaryPart

		local LinearVelocity = Instance.new("LinearVelocity")

		local att0: Attachment = PrimaryPart.Attachment

		LinearVelocity.Attachment0 = att0
		LinearVelocity.MaxForce = math.huge
		LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		LinearVelocity.VectorVelocity = p.Mouse * 150
		LinearVelocity.Enabled = true

		LinearVelocity.Parent = PrimaryPart

		Skill.Parent = Workspace.TerrainGraph

		local tickTime = 60
		local skillTicks = 1
		local totalTicks = tickTime * skillTicks
		HitboxService:CreateHitboxFromModel(Character, Skill, 1, totalTicks, function(hitted)
			StaffHitFunction(Character, hitted, 5, "MageM1", "Magic", nil)
			Skill:Destroy()
			return false
		end)

		local function DestroyParticle()
			PrimaryPart.Anchored = true
			for _, obj in Skill:GetDescendants() do
				if obj:IsA("ParticleEmitter") then
					obj.Enabled = false
				end
			end
			task.wait(1)
			Skill:Destroy()
		end

		local t = task.delay(skillTicks, function()
			if Skill:IsDescendantOf(Workspace) then
				DestroyParticle()
			end
		end)
	end,

	HSpell = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,

			Mouse: Vector3,
			From: CFrame,

			Combo: number,
			Combos: number,
		}
	)
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace.Enemies }

		local Skill = ReplicatedStorage.Essentials.Mages.BlueSkil:Clone()
		Skill:ScaleTo(5)
		Skill:PivotTo(p.From)
		local PrimaryPart = Skill.PrimaryPart

		local LinearVelocity = Instance.new("LinearVelocity")

		local att0: Attachment = PrimaryPart.Attachment

		LinearVelocity.Attachment0 = att0
		LinearVelocity.MaxForce = math.huge
		LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		LinearVelocity.VectorVelocity = p.Mouse * 150
		LinearVelocity.Enabled = true

		LinearVelocity.Parent = PrimaryPart

		Skill.Parent = Workspace.TerrainGraph

		local tickTime = 60
		local skillTicks = 5
		local totalTicks = tickTime * skillTicks
		HitboxService:CreateHitboxFromModel(Character, Skill, 1, totalTicks, function(hitted)
			StaffHitFunction(Character, hitted, 5, "MageM1", "Magic", 6)
			Skill:Destroy()
			return false
		end)

		task.delay(skillTicks, function()
			if Skill:IsDescendantOf(Workspace) then
				PrimaryPart.Anchored = true
				for _, obj in Skill:GetDescendants() do
					if obj:IsA("ParticleEmitter") then
						obj.Enabled = false
					end
				end
				task.wait(1)
				Skill:Destroy()
			end
		end)
	end,
}

Staff.TestStaff = Staff.Default

function Staff.Start(default)
	Default = default

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")
	SkillService = Knit.GetService("SkillService")

	HitboxService = Knit.GetService("HitboxService")

	ProgressionService = Knit.GetService("ProgressionService")
	CombatService = Knit.GetService("CombatService")

	PlayerService = Knit.GetService("PlayerService")
end

return Staff
