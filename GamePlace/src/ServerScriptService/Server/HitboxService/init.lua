local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Modules.Knit.Knit)

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

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

function HitboxService:CreateBlockHitbox(p: CFrame, s: Vector3, dmg: number, kb: number?, ovp: OverlapParams?)
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
		op.FilterType = Enum.RaycastFilterType.Whitelist
		op.FilterDescendantsInstances = { Workspace.Enemies }
	end

	local Damaged = {}
	local ParstInBoundBox = Workspace:GetPartBoundsInBox(p, s, op)

	for _, part in ipairs(ParstInBoundBox) do
		if part:IsA("BasePart") and part.Parent:IsA("Model") and part.Parent:FindFirstChild("Humanoid") then
			if not Damaged[part.Parent] then
				Damaged[part.Parent] = true
				local Humanoid = part.Parent:FindFirstChild("Humanoid")
				Humanoid:TakeDamage(dmg)

				if kb then
					Humanoid.RootPart.AssemblyLinearVelocity = (kb * p.LookVector) * GetModelMass(part.Parent)
				end

				VFX:ApplyParticle(part.Parent, "CombatHit")
				SFX:Apply(part.Parent, "Melee")
			end
		end
	end
end

return HitboxService
