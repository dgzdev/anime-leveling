local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RaycastHitbox = require(ReplicatedStorage.Modules.RaycastHitboxV4)
local GameData = require(ServerStorage.GameData)

local ProgressionService
local RenderService
local PlayerService
local RagdollService
local CombatService

local function GetModelMass(model: Model)
	if not model:IsA("Model") then
		return error("GetModelMass: model is not a Model.")
	end
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

local HitboxService = Knit.CreateService({
	Name = "HitboxService",
	Client = {
		killedEnemy = Knit.CreateSignal(),
	},
})

function HitboxService:CreateBlockHitbox(
	executor: Model,
	p: CFrame,
	s: Vector3,

	params: {
		dmg: number,
		time: number?,
		ragdoll: number?,
		op: OverlapParams?,
		kb: Vector3?,
		max: number?,
		replicate: {}?,
	}
)
	--[[
	local Part = Instance.new("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Size = s
	Part.CFrame = p
	Part.Name = "Hitbox"
	Part.Parent = Workspace
	Part.Transparency = 0.5
	Debris:AddItem(Part, 1)
	]]

	-- @executor: Model
	--character
	--inimigo

	local op: OverlapParams
	if params.op then
		op = params.op
	else
		op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace:FindFirstChild("Enemies") }
	end

	local Damaged = {}
	local PartsInBoundBox = Workspace:GetPartBoundsInBox(p, s, op)

	for _, part in ipairs(PartsInBoundBox) do
		if part:IsA("BasePart") and part.Parent:IsA("Model") and part.Parent:FindFirstChild("Humanoid") then
			if not Damaged[part.Parent] then
				Damaged[part.Parent] = true
				local Humanoid: Humanoid = part.Parent:FindFirstChild("Humanoid")

				if Humanoid.Health <= 0 then
					return
				end

				if params.ragdoll then
					RagdollService:Ragdoll(part.Parent, params.ragdoll)
				end

				if (Humanoid.Health - params.dmg) <= 0 then
					-- @executor -> character, @humanoid: Humanoid
					CombatService:RegisterHumanoidKilled(executor, Humanoid)
				end

				Humanoid:TakeDamage(params.dmg)

				if params.kb then
					Humanoid.RootPart.AssemblyLinearVelocity = (params.kb * p.LookVector) * GetModelMass(part.Parent)
				end

				if params.replicate then
					local replicate = params.replicate or {}
					replicate["root"] = Humanoid.RootPart
					RenderService:RenderForPlayers(replicate)
				end
			end
		end
	end
end

function HitboxService:CreateRaycastHitbox(
	Model: Model,
	params: {
		dmg: number,
		time: number?,
		kb: Vector3?,
		ragdoll: boolean?,
		max: number?,
		replicate: {}?,
	},
	rayparams: RaycastParams
)
	local dmg = params.dmg or 1
	local time = params.time or 1
	local kb = params.kb or 0
	local max = params.kb or 250
	local replicate = params.replicate or {}

	local Damaged = {}

	local hitbox = RaycastHitbox.new(Model)
	local executor = Model:FindFirstAncestorWhichIsA("Model")

	if rayparams then
		hitbox.RaycastParams = rayparams
	end

	hitbox.OnHit:Connect(function(hit, humanoid)
		if not Damaged[hit] then
			hitbox:HitStop()
			Damaged[hit] = true
			--if humanoid.Health <= 0 then
			--	return
			--end

			if humanoid.Health <= 0 then
				return
			end

			if params.ragdoll then
				RagdollService:Ragdoll(humanoid.Parent, params.ragdoll)
			end

			-- se matou e se o executor for jogador
			if (humanoid.Health - dmg) <= 0 then
				CombatService:RegisterHumanoidKilled(executor, humanoid)
			end

			humanoid:TakeDamage(dmg)

			if params.replicate then
				replicate["root"] = humanoid.RootPart
				RenderService:RenderForPlayers(replicate)
			end

			if kb then
				humanoid.RootPart.AssemblyLinearVelocity = kb * GetModelMass(hit)
			end
		end
	end)
	hitbox:HitStart(time)
end

function HitboxService:KnitStart()
	ProgressionService = Knit.GetService("ProgressionService")
	RenderService = Knit.GetService("RenderService")
	PlayerService = Knit.GetService("PlayerService")
	RagdollService = Knit.GetService("RagdollService")
	CombatService = Knit.GetService("CombatService")
end

return HitboxService
