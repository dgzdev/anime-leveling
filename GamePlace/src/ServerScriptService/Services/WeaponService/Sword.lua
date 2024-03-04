local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Sword = {}

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
			mass += part:GetMass()
		end
	end
	return mass
end

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
			time = 1,
			kb = 15,
			max = 250,
			replicate = {
				["module"] = "Universal",
				["effect"] = "Replicate",
				["VFX"] = "SwordHit",
				["SFX"] = "SwordHit",
			},
		}

		local weapon = Character:FindFirstChild("Weapon")
		if not weapon then
			return
		end

		local damage = 10

		Hitbox2Service:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 2.5)
					* GetModelMass(hitted)

				Humanoid:TakeDamage(damage)
			end
		end)
	end,

	Defense = function(...)
		print("Defense")
	end,

	FlashStrike = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -30)

		RenderService:RenderForPlayersInArea(Mid.Position, 200, {
			module = "Universal",
			effect = "FlashStrike",
			root = Character.PrimaryPart,
		})

		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace.Enemies }

		Hitbox2Service:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 30, function(hitted)
			local damage = 10
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 15)
					* GetModelMass(hitted)
				ApplyRagdoll(hitted, 2)
				Humanoid:TakeDamage(damage)
				return false
			end
		end, op)
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

Sword.LuxurySword = {
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
			time = 1,
			kb = 15,
			max = 250,
			replicate = {
				["module"] = "Universal",
				["effect"] = "Replicate",
				["VFX"] = "LightningSwordHit",
				["SFX"] = "SwordHit",
			},
		}

		local weapon = Character:FindFirstChild("Weapon")
		if not weapon then
			return
		end

		local damage = 10

		Hitbox2Service:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 1.5)
					* GetModelMass(hitted)
				Humanoid:TakeDamage(damage)
			end
		end)
	end,

	Defense = function(...)
		Sword.Default.Defense(...)
	end,

	FlashStrike = function(
		Character: Model,
		InputState: Enum.UserInputState,
		Data: { Position: CFrame, Camera: CFrame }
	)
		local Mid = Data.Position * CFrame.new(0, 0, -30)

		local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not Root then
			return
		end

		RenderService:RenderForPlayersInArea(Mid.Position, 200, {
			module = "Lightning",
			effect = "FlashStrike",
			root = Root,
		})

		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace.Enemies }

		Hitbox2Service:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 30, function(hitted)
			local damage = 10
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 25)
					* GetModelMass(hitted)
				ApplyRagdoll(hitted, 2)
				Humanoid:TakeDamage(damage)
			end
		end, op)

		RenderService:RenderForPlayersInArea(Mid.Position, 200, {
			["module"] = "Universal",
			["effect"] = "Replicate",
			["VFX"] = "SlashHit",
			root = Character.PrimaryPart,
		})
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

		local Distance = 120

		local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not Root then
			return
		end

		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { Workspace.Enemies }

		RenderService:RenderForPlayersInArea(Root.CFrame.Position, 200, {
			module = "Lightning",
			effect = "Lightning",
			root = Root,
		})

		Hitbox2Service:CreateFixedHitbox(Mid, Vector3.new(5, 5, Size), 32, function(hitted)
			local damage = 10
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")
			if not Root then
				return
			end

			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end

				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 15)
					* GetModelMass(hitted)
				ApplyRagdoll(hitted, 3)
				Humanoid:TakeDamage(damage)
			end
		end)
	end,
}

function Sword.Start(default)
	default = default

	Knit.OnStart()

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")

	HitboxService = Knit.GetService("HitboxService")
	Hitbox2Service = Knit.GetService("Hitbox2Service")

	CombatService = Knit.GetService("CombatService")
end

return Sword
