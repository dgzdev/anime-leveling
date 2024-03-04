local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Melee = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Default

local HitboxService
local Hitbox2Service
local RagdollService
local RenderService
local CombatService

local function GetModelMass(model: Model): number
	local mass = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

local function ApplyRagdoll(model: Model, time: number)
	RagdollService:Ragdoll(model, time)
end

Melee.Default = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		Hitbox2Service:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 25, function(hitted: Model)
			local Humanoid = hitted:FindFirstChildWhichIsA("Humanoid")

			local damage = 10
			if Humanoid then
				if Humanoid:GetAttribute("Died") then
					return
				end
				if (Humanoid.Health - damage) <= 0 then
					Humanoid:SetAttribute("Died", true)
					CombatService:RegisterHumanoidKilled(Character, Humanoid)
				end

				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 5)
					* GetModelMass(hitted)
				Humanoid:TakeDamage(damage)
			end
		end, op)
	end,

	Defense = function(...)
		Default.Defense(...)
	end,
}

-- item melee
Melee.Melee = {
	Attack = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
			Combo: number,
			Combos: number,
		}
	)
		Melee.Default.Attack(Character, InputState, p)
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
		Melee.Default.Defense(Character, InputState, p)
	end,

	["Strong Punch"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		--[[
			function HitboxService:CreatePartHitbox(Character: Model, HitboxSize: Vector3, Ticks: number, callback: any)

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
					Humanoid:TakeDamage(damage)
				end

		]]

		Hitbox2Service:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 25, function(hitted)
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
				ApplyRagdoll(hitted, 2)
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 15)
					* GetModelMass(hitted)
				Humanoid:TakeDamage(damage)
			end
		end, op)
	end,
	["Ground Slam"] = function(
		Character: Model,
		InputState: Enum.UserInputState,
		p: {
			Position: CFrame,
		}
	)
		local op = OverlapParams.new()

		if Character:GetAttribute("Enemy") then
			local Characters = {}
			for _, plrs in ipairs(Players:GetPlayers()) do
				table.insert(Characters, plrs.Character)
			end

			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = Characters
		else
			op.FilterType = Enum.RaycastFilterType.Include
			op.FilterDescendantsInstances = { Workspace:WaitForChild("Enemies") }
		end

		Hitbox2Service:CreatePartHitbox(Character, Vector3.new(25, 5, 25), 35, function(hitted)
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
				ApplyRagdoll(hitted, 2)
				Humanoid.RootPart.AssemblyLinearVelocity = (Character.PrimaryPart.CFrame.LookVector * 10)
					* GetModelMass(hitted)
				Humanoid:TakeDamage(damage)
			end
		end, op)

		RenderService:RenderForPlayersInArea(p.Position.Position, 100, {
			["module"] = "Melee",
			["effect"] = "GroundSlam",
			root = Character.PrimaryPart,
		})
	end,
}
function Melee.Start(default)
	default = default

	HitboxService = Knit.GetService("HitboxService")
	Hitbox2Service = Knit.GetService("Hitbox2Service")
	RenderService = Knit.GetService("RenderService")
	CombatService = Knit.GetService("CombatService")
	RagdollService = Knit.GetService("RagdollService")
end

return Melee
