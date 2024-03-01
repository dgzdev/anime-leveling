local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Sword = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

local LightningBolt = require(ReplicatedStorage.Modules.LightningBolt)
local LightningSparks = require(ReplicatedStorage.Modules.LightningSparks)
local LightningExplosion = require(ReplicatedStorage.Modules.LightningExplosion)

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
		local Model = Character:FindFirstChild("Weapon")
		if not Model then
			return
		end

		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace.Enemies }

		local Params = {
			dmg = 10,
			time = 2,
			kb = 15,
			max = 250,
			replicate = {
				["module"] = "Universal",
				["effect"] = "Replicate",
				["VFX"] = "SwordHit",
				["SFX"] = "SwordHit",
			},
		}

		HitboxService:CreateRaycastHitbox(Model, Params, Ray)
	end,

	Defense = function(...)
		print("Defense")
	end,

	FlashStrike = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -30)
		local Size = 60

		local Rayparams = RaycastParams.new()
		Rayparams.FilterType = Enum.RaycastFilterType.Exclude
		Rayparams.FilterDescendantsInstances = { Character }
		local RaycastResult = Workspace:Raycast(Data.Position.Position, Data.Position.LookVector * 60, Rayparams)
		if RaycastResult then
			local Distance = (Data.Position.Position - RaycastResult.Position).Magnitude
			Mid = Data.Position * CFrame.new(0, 0, -(Distance / 2))
			Size = Distance
		end

		RenderService:RenderForPlayersInArea(Mid.Position, 200, {
			module = "Universal",
			effect = "FlashStrike",
			root = Character.PrimaryPart,
		})

		VFX:ApplyParticle(Character, "Slash", nil, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0))

		-- blz

		--[[ -> ISSO AQ E SO DEBUG
			local part = Instance.new("Part")
			part.Size = Vector3.new(5, 5, Size)
			part.CFrame = Mid
			part.Anchored = true
			part.CanCollide = false
			part.Parent = Workspace
			part.Transparency = 0.6
			Debris:AddItem(part, 2)
		]]

		local OverlapParams = OverlapParams.new()
		OverlapParams.FilterType = Enum.RaycastFilterType.Include
		OverlapParams.FilterDescendantsInstances = { Workspace.Enemies }

		local Damaged = {}

		local PartInBoundBox = Workspace:GetPartBoundsInBox(Mid, Vector3.new(5, 5, Size), OverlapParams)
		for _, Part: BasePart in ipairs(PartInBoundBox) do
			local Model = Part:FindFirstAncestorWhichIsA("Model")
			if not Model then
				continue
			end

			local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
			if not Humanoid then
				continue
			end

			if Damaged[Humanoid] then
				continue
			end

			local Root: BasePart = Model.PrimaryPart
			if not Root then
				continue
			end

			Damaged[Humanoid] = true

			Humanoid:TakeDamage(10)
			RagdollService:Ragdoll(Model, 1.5)

			local V = (Data.Position.LookVector * 15) * GetModelMass(Model)
			Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 15, 0)

			VFX:ApplyParticle(Model, "SwordHit")
			SFX:Apply(Model, "SwordHit")
			return
		end
		if #Damaged > 0 then
			VFX:ApplyParticle(Character, "SlashHit", nil, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0))
		end
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

Sword["King'sLongsword"] = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: { Position: CFrame, Combo: number, Combos: number }
	)
		local Model = Character:FindFirstChild("Weapon")
		if not Model then
			return
		end

		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace:FindFirstChild("Enemies") }

		local Params = {
			dmg = 10,
			time = 2,
			kb = 15,
			max = 250,
			replicate = {
				["module"] = "Universal",
				["effect"] = "Replicate",
				["VFX"] = "SwordHit",
				["SFX"] = "SwordHit",
			},
		}

		HitboxService:CreateRaycastHitbox(Model, Params, Ray)
	end,

	Defense = function(...)
		Sword.Default.Defense(...)
	end,

	FlashStrike = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -30)
		local Size = 60

		local Rayparams = RaycastParams.new()
		Rayparams.FilterType = Enum.RaycastFilterType.Exclude
		Rayparams.FilterDescendantsInstances = { Character }
		local RaycastResult = Workspace:Raycast(Data.Position.Position, Data.Position.LookVector * 60, Rayparams)
		if RaycastResult then
			local Distance = (Data.Position.Position - RaycastResult.Position).Magnitude
			Mid = Data.Position * CFrame.new(0, 0, -(Distance / 2))
			Size = Distance
		end

		RenderService:RenderForPlayersInArea(Mid.Position, 200, {
			module = "Lightning",
			effect = "FlashStrike",
			root = Character.PrimaryPart,
		})

		VFX:ApplyParticle(Character, "Slash", nil, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0))

		-- blz

		--[[ -> ISSO AQ E SO DEBUG
			local part = Instance.new("Part")
			part.Size = Vector3.new(5, 5, Size)
			part.CFrame = Mid
			part.Anchored = true
			part.CanCollide = false
			part.Parent = Workspace
			part.Transparency = 0.6
			Debris:AddItem(part, 2)
		]]

		local OverlapParams = OverlapParams.new()
		OverlapParams.FilterType = Enum.RaycastFilterType.Include
		OverlapParams.FilterDescendantsInstances = { Workspace.Enemies }

		local Damaged = {}

		local PartInBoundBox = Workspace:GetPartBoundsInBox(Mid, Vector3.new(5, 5, Size), OverlapParams)
		for _, Part: BasePart in ipairs(PartInBoundBox) do
			local Model = Part:FindFirstAncestorWhichIsA("Model")
			if not Model then
				continue
			end

			local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
			if not Humanoid then
				continue
			end

			if Damaged[Humanoid] then
				continue
			end

			if Humanoid.Health <= 0 then
				continue
			end

			local Root: BasePart = Model.PrimaryPart
			if not Root then
				continue
			end

			Damaged[Humanoid] = true

			Humanoid:TakeDamage(10)
			RagdollService:Ragdoll(Model, 1.5)

			local V = (Data.Position.LookVector * 15) * GetModelMass(Model)
			Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 5, 0)

			SFX:Apply(Model, "SwordHit")
			VFX:ApplyParticle(Model, "LightningSwordHit")
			return
		end
		if #Damaged > 0 then
			VFX:ApplyParticle(Character, "SlashHit", nil, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0))
		end
	end,

	["Eletric Wave"] = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -60)
		local InitialSize = Vector3.new(5, 5, 5)
		local FinalSize = Vector3.new(60, 5, 5)

		local effectPart = Instance.new("Part")
		effectPart.Size = InitialSize
		effectPart.CFrame = Data.Position
		effectPart.Anchored = true
		effectPart.CanCollide = false
		effectPart.Transparency = 1
		effectPart.Parent = Workspace:WaitForChild("VFXs")

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

			if not Part:IsDescendantOf(Workspace.Enemies) then
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

			local V = (Data.Position.LookVector * 15) * GetModelMass(Model)
			Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 15, 0)

			VFX:ApplyParticle(Model, "LightningSwordHit")
			VFX:ApplyParticle(Model, "Fell")
			SFX:Create(Model, "LightningFlashesQuick", 0, 70)
		end)
		return
	end,

	Lightning = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -30)
		local Size = Vector3.new(7, 7, 60)

		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace.Enemies }

		local Parts = Workspace:GetPartBoundsInBox(Mid, Size, op)
		for _, Part: BasePart in ipairs(Parts) do
			local Model = Part:FindFirstAncestorWhichIsA("Model")
			if not Model then
				continue
			end

			local Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
			if not Humanoid then
				continue
			end

			if Humanoid.Health <= 0 then
				continue
			end

			local Root: BasePart = Model.PrimaryPart
			if not Root then
				continue
			end

			RenderService:RenderForPlayersInArea(Root.CFrame.Position, 200, {
				module = "Lightning",
				effect = "Lightning",
				root = Root,
			})

			task.delay(0.65, function()
				Humanoid:TakeDamage(50)
				RagdollService:Ragdoll(Model, 2)

				local V = (Data.Position.LookVector * 15) * GetModelMass(Model)
				Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 15, 0)

				SFX:Create(Model, "Lightning", 0, 120)
			end)

			return
		end
	end,
}

function Sword.Start(default)
	default = default

	Knit.OnStart()

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
end

return Sword
