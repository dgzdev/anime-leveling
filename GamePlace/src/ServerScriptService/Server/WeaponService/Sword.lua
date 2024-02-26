local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Sword = {}
local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)

local Default
local RenderService

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
		print("Attack")
	end,

	Defense = function(...)
		print("Defense")
	end,
}

Sword.IronStarterSword = {
	Attack = function(...)
		Sword.Default.Attack(...)
	end,

	Defense = function(...)
		Sword.Default.Defense(...)
	end,

	FlashStrike = function(Character: Model, InputState: Enum.UserInputState, Data: { Position: CFrame })
		local Mid = Data.Position * CFrame.new(0, 0, -30)
		local Size = 60

		local Rayparams = RaycastParams.new()
		Rayparams.FilterType = Enum.RaycastFilterType.Blacklist
		Rayparams.FilterDescendantsInstances = { Character }
		local RaycastResult = Workspace:Raycast(Data.Position.Position, Data.Position.LookVector * 60, Rayparams)
		if RaycastResult then
			local Distance = (Data.Position.Position - RaycastResult.Position).Magnitude
			Mid = Data.Position * CFrame.new(0, 0, -(Distance / 2))
			Size = Distance
		end

		local RenderData = RenderService:CreateRenderData(Character.Humanoid, "FlashStrike", "Test", { "Bunda" })
		RenderService:RenderForPlayers(RenderData)
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
			Humanoid:TakeDamage(100)

			local V = (Data.Position.LookVector * 15) * GetModelMass(Model)
			Humanoid.RootPart.AssemblyLinearVelocity = V

			VFX:ApplyParticle(Model, "SwordHit")
			SFX:Apply(Model, "SwordHit")
			return
		end
	end,
}

function Sword.Start(default)
	default = default
	RenderService = Knit.GetService("RenderService")
end

return Sword
