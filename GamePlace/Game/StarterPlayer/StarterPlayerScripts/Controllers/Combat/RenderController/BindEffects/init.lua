local Knit = require(game.ReplicatedStorage.Packages.Knit)
local BindEffects = {}

local RenderController
local TweenService = game:GetService("TweenService")

function BindEffects.CustomAdd(RenderData)
	local Effects = {
		AuraDark = function()
			local HighlightFind = game.ReplicatedStorage.VFX.Highlight:FindFirstChild("AuraDarkHighlight", true)

			if not HighlightFind then
				return
			end

			local Highlight: Highlight = RenderController:CreateInstance(BindEffects, RenderData.casterHumanoid, HighlightFind:Clone())
			Highlight.FillTransparency = 1
			Highlight.OutlineTransparency = 1

			TweenService:Create(Highlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FillTransparency = 0, OutlineTransparency = 0}):Play()
			Highlight.Parent = RenderData.casterHumanoid.Parent
		end,
		Loot_E = function()
		end,
		Loot_D = function()
		end,
		Loot_C = function()
		end,
		Loot_B = function()
		end,
		Loot_A = function()
		end,
		Loot_S = function()
		end
	}

	if Effects[RenderData.arguments] then
		Effects[RenderData.arguments]()
	end
end

function BindEffects.CustomRemove(RenderData)
	local Effects = {
		AuraDark = function()
			RenderController:ClearInstance(BindEffects, RenderData.casterHumanoid, "AuraDarkHighlight")
		end,
	}

	if Effects[RenderData.arguments] then
		Effects[RenderData.arguments]()
	end
end

local function AssemblyPart(BasePart: BasePart)
	BasePart.CanCollide = false
	BasePart.CanQuery = false
	BasePart.CanTouch = false
	BasePart.Massless = true
	BasePart.Anchored = false
end

function BindEffects.Add(RenderData)
	local casterHumanoid: Humanoid = RenderData.casterHumanoid
	local effect: string = RenderData.arguments 

	local Effect = game.ReplicatedStorage.VFX:FindFirstChild(effect, true)

	if not Effect then
		return
	end

	local haveEffect = RenderController:GetInstance(BindEffects, casterHumanoid, effect)
	if haveEffect then
		return
	end

	print(RenderData)
	BindEffects.CustomAdd(RenderData)

	local EffectClone = RenderController:CreateInstance(BindEffects, casterHumanoid, Effect:Clone()) :: BasePart

	if EffectClone:IsA("BasePart") then
		AssemblyPart(EffectClone)
	end

	for _, v: BasePart in EffectClone:GetDescendants() do
		if v:IsA("BasePart") then
			AssemblyPart(v)
		end
	end
	
	if RenderData.NotHumanoid :: boolean then
		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = casterHumanoid
		Weld.Part1 = EffectClone
		Weld.Parent = EffectClone

		EffectClone:PivotTo(casterHumanoid.CFrame)
		EffectClone.Parent = casterHumanoid
	else
		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = casterHumanoid.RootPart
		Weld.Part1 = EffectClone
		Weld.Parent = EffectClone

		EffectClone:PivotTo(casterHumanoid.RootPart:GetPivot())
		EffectClone.Parent = casterHumanoid.Parent
	end


	RenderController:EmitParticles(EffectClone)
end

function BindEffects.Remove(RenderData)
	local casterHumanoid: Humanoid = RenderData.casterHumanoid
	local effect: string = RenderData.arguments 

	local haveEffect = RenderController:GetInstance(BindEffects, casterHumanoid, effect)
	print(haveEffect)
	if not haveEffect then
		return
	end

	RenderController:ClearInstance(BindEffects, casterHumanoid, effect)

	BindEffects.CustomRemove(RenderData)
end

function BindEffects.Caller(RenderData)
	local Effect = RenderData.effect

	if BindEffects[Effect] then
		BindEffects[Effect](RenderData)
	else
		print("Effect not found")
	end
end

function BindEffects.Start()
	RenderController = Knit.GetController("RenderController")
end

return BindEffects