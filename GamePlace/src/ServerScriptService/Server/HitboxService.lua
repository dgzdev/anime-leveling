local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RaycastHitbox = require(ReplicatedStorage.Modules.RaycastHitboxV4)

local RenderService

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
	Client = {},
})

function HitboxService:CreateBlockHitbox(
	p: CFrame,
	s: Vector3,
	dmg: number,
	kb: number?,
	ovp: OverlapParams?,
	vfx: string?,
	sfx: string?
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

	local op: OverlapParams
	if ovp then
		op = ovp
	else
		op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace:FindFirstChild("Enemies") }
	end

	local Damaged = {}
	local ParstInBoundBox = Workspace:GetPartBoundsInBox(p, s, op)

	for _, part in ipairs(ParstInBoundBox) do
		if part:IsA("BasePart") and part.Parent:IsA("Model") and part.Parent:FindFirstChild("Humanoid") then
			if not Damaged[part.Parent] then
				Damaged[part.Parent] = true
				local Humanoid: Humanoid = part.Parent:FindFirstChild("Humanoid")
				if Humanoid.Health <= 0 then
					return
				end

				Humanoid:TakeDamage(dmg)

				if kb then
					Humanoid.RootPart.AssemblyLinearVelocity = (kb * p.LookVector) * GetModelMass(part.Parent)
				end

				VFX:ApplyParticle(part.Parent, vfx or "CombatHit")
				SFX:Apply(part.Parent, sfx or "Melee")
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

	if rayparams then
		hitbox.RaycastParams = rayparams
	end

	hitbox.OnHit:Connect(function(hit, humanoid)
		if not Damaged[hit] then
			Damaged[hit] = true
			if humanoid.Health <= 0 then
				return
			end

			humanoid:TakeDamage(dmg)

			replicate["root"] = humanoid.RootPart
			RenderService:RenderForPlayers(replicate)

			if kb then
				humanoid.RootPart.AssemblyLinearVelocity = kb * GetModelMass(hit)
			end
		end
	end)
	hitbox:HitStart(time)
end

function HitboxService:KnitStart()
	RenderService = Knit.GetService("RenderService")
end

return HitboxService
