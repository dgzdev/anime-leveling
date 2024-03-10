local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService = Knit.GetService("HitboxService")
local WeaponService = Knit.GetService("WeaponService")
local RenderService = Knit.GetService("RenderService")
local RagdollService = Knit.GetService("RagdollService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

return function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
	local Mid = Data.Position * CFrame.new(0, 0, -60)
	local InitialSize = Vector3.new(5, 5, 5)
	local FinalSize = Vector3.new(60, 5, 5)

	local effectPart = Instance.new("Part")
	effectPart.Size = InitialSize
	effectPart.CFrame = Data.Position
	effectPart.Anchored = true
	effectPart.CanCollide = false
	effectPart.Transparency = 1
	effectPart.Parent = workspace:WaitForChild("VFXs")

	VFX:CreateInfinite(effectPart, "InfiniteLightning")

	RenderService:RenderForPlayersInArea(Mid.Position, 200, {
		module = "Lightning",
		effect = "LightningWave",
		root = Character.PrimaryPart,
	})

	SFX:Create(effectPart, "LightningFlashes", 0, 120, true)

	local Tween = game:GetService("TweenService"):Create(
		effectPart,
		TweenInfo.new(1.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ Size = FinalSize, CFrame = Mid }
	)
	Tween:Play()
	Tween.Completed:Connect(function(playbackState)
		for _, p: ParticleEmitter in ipairs(effectPart:GetChildren()) do
			if p:IsA("ParticleEmitter") then
				p.Enabled = false
			end
		end
		task.wait(1)
		effectPart:Destroy()
	end)

	local Damaged = {}
	effectPart.Touched:Connect(function(Part)
		local Model = Part:FindFirstAncestorWhichIsA("Model")
		if not Model then
			return
		end

		if Part:IsDescendantOf(Character) then
			return
		end

		if not Part:IsDescendantOf(workspace:WaitForChild("Enemies")) then
			return
		end

		local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid then
			return
		end

		if Humanoid.Health <= 0 then
			return
		end

		if Damaged[Humanoid] then
			return
		end

		local Root: BasePart = Model.PrimaryPart
		if not Root then
			return
		end

		Damaged[Humanoid] = true

		Humanoid:TakeDamage(30)
		RagdollService:Ragdoll(Model, 1.5)

		local V = (Data.Position.LookVector * 30) * GetModelMass(Model)
		Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 15, 0)

		VFX:ApplyParticle(Model, "LightningSwordHit")
		VFX:ApplyParticle(Model, "Fell")
		SFX:Create(Model, "LightningFlashesQuick", 0, 70)
	end)
end
