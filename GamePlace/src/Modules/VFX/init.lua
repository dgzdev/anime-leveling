local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VFX = {}

local VFXFolder = ReplicatedStorage.VFX

function VFX:ApplyParticle(target: Model, action: string, time: number?, offset: Vector3?, doNotWeld: boolean?)
	local block = VFXFolder:FindFirstChild(action)
	if not block then
		return error("VFX not found")
	end

	local particle = block:Clone() :: BasePart
	particle.Parent = target:WaitForChild("HumanoidRootPart")
	particle.Transparency = 1
	particle.Massless = true
	particle.CanCollide = false
	particle.Anchored = false
	particle.CollisionGroup = "VFX"
	particle.CFrame = target.PrimaryPart.CFrame * CFrame.new(offset or Vector3.new(0, 0, 0))

	if doNotWeld then
		particle.Anchored = true
	else
		local w = Instance.new("WeldConstraint", particle)
		w.Part0 = target.PrimaryPart
		w.Part1 = particle
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

return VFX
