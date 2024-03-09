local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Dagger = {}

local Knit = require(ReplicatedStorage.Packages.Knit)

local Default

local RenderService
local RagdollService
local HitboxService
local PlayerService
local ProgressionService
local CombatService

local function ApplyRagdoll(model: Model, time: number)
	RagdollService:Ragdoll(model, time)
end

local GameData = require(ServerStorage.GameData)

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

local DaggerHitFunction = function(
	Character: Model,
	hitted: Model,
	kb: number,
	vfx: string,
	sfx: string,
	dmg: number?,
	ragdoll: number?
)
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

Dagger.Default = {
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
				DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", nil, 0)
			end)
		end
	end,

	Defense = function(...)
		print("Defense")
	end,
}

Dagger["Venom'sFangs"] = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Dagger.Default.Attack(Character, InputState, p)
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
		Dagger.Default.Defense(Character, InputState, p)
	end,

	["teste"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		print("server recebeu")

		RenderService:RenderForPlayersInArea(p.Position.Position, 200, {
			module = "Lightning",
			effect = "FlashStrike",
			root = Character.PrimaryPart,
		})
	end,

	["LStrike"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local CFramePosition = p.Position --> Posicao de onde ele clicou pra soltar o ataque

		local Ray = RaycastParams.new()
		Ray.FilterType = Enum.RaycastFilterType.Exclude
		Ray.FilterDescendantsInstances = { Character, Workspace.Enemies, Workspace.NPC }

		local Distance = 45

		local RayResult = Workspace:Raycast(CFramePosition.Position, CFramePosition.LookVector * Distance, Ray)
		if RayResult then
			Distance = (CFramePosition.Position - RayResult.Position).Magnitude ---distancia q ele deve teleportar
		end

		RenderService:RenderForPlayersInArea(CFramePosition.Position, 200, {
			module = "Lightning",
			effect = "LStrike",
			root = Character.PrimaryPart,
		})

		task.spawn(function()
			local Ticks = 5

			local Highlight = Instance.new("Highlight")
			Highlight.Parent = Character

			Highlight.FillColor = Color3.new(0, 0, 0)
			Highlight.FillTransparency = 0.1
			Highlight.OutlineTransparency = 0.5
			Highlight.OutlineColor = Color3.new(1, 1, 1)

			Highlight.Enabled = true

			for i = 1, Ticks do
				Highlight.Enabled = not Highlight.Enabled
				task.wait(0.1)
			end

			Highlight:Destroy()
		end)

		Character:PivotTo(Character:GetPivot() * CFrame.new(0, 0, -Distance))

		local Size = Vector3.new(5, 5, Distance)
		HitboxService:CreateFixedHitbox(
			CFramePosition * CFrame.new(0, 0, -(Distance / 2)),
			Size,
			32,
			function(hitted: Model)
				--> Encontrou um inimigo
				DaggerHitFunction(Character, hitted, 5, "DaggerHit", "DaggerHit", 2, 0)
			end
		)
	end,
}

function Dagger.Start(default)
	Default = default

	RenderService = Knit.GetService("RenderService")
	RagdollService = Knit.GetService("RagdollService")

	HitboxService = Knit.GetService("HitboxService")
	HitboxService = Knit.GetService("HitboxService")

	CombatService = Knit.GetService("CombatService")
	ProgressionService = Knit.GetService("ProgressionService")
	PlayerService = Knit.GetService("PlayerService")
end

return Dagger
