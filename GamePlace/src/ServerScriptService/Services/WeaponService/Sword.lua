local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Sword = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService
local CombatService
local PlayerService
local ProgressionService

local GameData = require(ServerStorage.GameData)

local function CalculateDamage(BaseDamage)
	local LocalStatus = ProgressionService.LocalStatus

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

local SwordHitFunction = function(
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
	if not data then
		return
	end

	local weapon = data.Equiped.Weapon
	local weaponData = GameData.gameWeapons[weapon]
	if not weaponData then
		return
	end

	dmg = dmg or 1

	local damage = CalculateDamage(weaponData.Damage * dmg)
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

		HitboxService:CreateStun(hitted, 0.75, function()
			if rag > 0 then
				ApplyRagdoll(hitted, rag)
			end
		end)

		Humanoid:TakeDamage(damage)
		return false
	end
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
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace.Enemies }

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "SwordHit", "SwordHit", nil, 0)
			end)
		end
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

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "SwordHit", "SwordHit", nil, 0)
			end, op)
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
		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Include
		Ray.FilterDescendantsInstances = { Workspace:FindFirstChild("Enemies") }

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "LightningSwordHit", "SwordHit", nil, 0)
			end)
		end
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

		local WeaponFolder = Character:FindFirstChild("Weapons")
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitboxFromModel(Character, weapon, 1, 32, function(hitted: Model)
				SwordHitFunction(Character, hitted, 5, "LightningSwordHit", "SwordHit", nil, 0)
			end, op)
		end

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

			local V = (Data.Position.LookVector * 30) * GetModelMass(Model)
			Humanoid.RootPart.AssemblyLinearVelocity = V + Vector3.new(0, 15, 0)

			VFX:ApplyParticle(Model, "LightningSwordHit")
			VFX:ApplyParticle(Model, "Fell")
			SFX:Create(Model, "LightningFlashesQuick", 0, 70)
		end)
		return
	end,

	Lightning = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Size = Vector3.new(7, 7, 60)

		local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if not Root then
			return
		end

		local WeaponFolder = Character:FindFirstChild("Weapons")
		local alreadyHitted = false
		for i, weapon: Model in ipairs(WeaponFolder:GetChildren()) do
			HitboxService:CreateHitbox(Character, Size, 16, function(hitted: Model | BasePart)
				if alreadyHitted then
					return "break"
				end

				alreadyHitted = true
				SwordHitFunction(Character, hitted, 30, "LightningSwordHit", "SwordHit", 2, 2)

				if hitted:IsA("Accessory") then
					hitted = hitted.Parent
				end

				RenderService:RenderForPlayersInArea(Root.CFrame.Position, 200, {
					module = "Lightning",
					effect = "Lightning",
					root = hitted.PrimaryPart or hitted,
				})

				return "break"
			end)
		end
	end,
}

function Sword.Start(default)
	default = default

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")

	HitboxService = Knit.GetService("HitboxService")
	HitboxService = Knit.GetService("HitboxService")

	ProgressionService = Knit.GetService("ProgressionService")
	CombatService = Knit.GetService("CombatService")

	PlayerService = Knit.GetService("PlayerService")
end

return Sword
