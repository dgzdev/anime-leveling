local Knit = require(game.ReplicatedStorage.Packages.Knit)

local HitEffects = {}

local SFX = require(game.ReplicatedStorage.Modules.SFX)

local EffectsFolder = game.ReplicatedStorage.VFX.HitEffects
local Debris = game:GetService("Debris")
local RenderController

function HitEffects.Default(RenderData)
	local casterHumanoid: Humanoid = RenderData.casterHumanoid

	local Effect = EffectsFolder[RenderData.effect]:Clone()

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = casterHumanoid.RootPart
	Weld.Part1 = Effect
	Weld.Parent = Effect

	Effect:PivotTo(casterHumanoid.RootPart:GetPivot())
	Effect.Parent = casterHumanoid.Parent

	SFX:Apply(casterHumanoid.RootPart, RenderData.effect .. "Hit")

	RenderController:EmitParticles(Effect)

	Debris:AddItem(Effect, 2)
end

function HitEffects.Caller(RenderData)
	HitEffects.Default(RenderData)
end

function HitEffects.Start()
	RenderController = Knit.GetController("RenderController")
end

return HitEffects
