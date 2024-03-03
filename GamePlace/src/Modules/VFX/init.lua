local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VFX = {}

local VFXFolder = ReplicatedStorage.VFX

function VFX:_ApplyParticle(
	target: BasePart | Model | Part | nil,
	action: string,
	time: number?,
	offset: CFrame | Vector3 | nil,
	doNotWeld: boolean?,
	v: Vector3?
)
	local Root
	if target:IsA("BasePart") then
		Root = target
	elseif target:IsA("Model") then
		Root = target.PrimaryPart
	end

	local block = VFXFolder:FindFirstChild(action)
	if not block then
		return error("VFX not found")
	end

	local particle = block:Clone() :: BasePart
	particle.Parent = Root
	particle.Transparency = 1
	particle.Massless = true
	particle.CanCollide = false
	particle.Anchored = false
	particle.CollisionGroup = "VFX"
	if typeof(offset) == "Vector3" then
		offset = CFrame.new(offset)
	end
	particle.CFrame = Root.CFrame * (offset or CFrame.new(0, 0, 0))

	if doNotWeld then
		particle.Anchored = true
	else
		local w = Instance.new("WeldConstraint", particle)
		w.Part0 = Root
		w.Part1 = particle
	end

	if v then
		for _, p: ParticleEmitter in ipairs(particle:GetDescendants()) do
			if p:IsA("ParticleEmitter") then
				p.Acceleration = v
			end
		end
	end

	particle.Parent = Workspace.VFXs

	for _, pe: ParticleEmitter in ipairs(particle:GetDescendants()) do
		if pe:IsA("ParticleEmitter") then
			local c = pe:GetAttribute("EmitCount") or 1
			local emitDelay = pe:GetAttribute("EmitDelay") or 0.1
			task.wait(emitDelay)
			pe:Emit(tonumber(c))
		end
		task.wait()
	end

	Debris:AddItem(particle, time or 2)
	return particle
end

function VFX:ApplyParticle(
	target: Model,
	action: string,
	time: number?,
	offset: CFrame?,
	doNotWeld: boolean?,
	v: Vector3?
)
	task.spawn(function()
		self:_ApplyParticle(target, action, time, offset, doNotWeld, v)
	end)
end

function VFX:_CreateInfinite(target: Model | BasePart, action: string)
	local block = VFXFolder:FindFirstChild(action)
	if not block then
		return error("VFX not found")
	end

	if target:IsA("Model") then
		target = target.PrimaryPart
	end

	local pls = {}
	for _, p in ipairs(block:GetChildren()) do
		p = p:Clone()
		pls[#pls + 1] = p
		p.Parent = target
	end
end

function VFX:CreateInfinite(target: Model, action: string)
	task.spawn(function()
		self:_CreateInfinite(target, action)
	end)
end

return VFX
