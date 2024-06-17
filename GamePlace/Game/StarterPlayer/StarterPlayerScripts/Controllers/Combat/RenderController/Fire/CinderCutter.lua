local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local CinderCutter = {}

local TweenService = game:GetService("TweenService")
local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)
local CraterModule = require(game.ReplicatedStorage.Modules.CraterModule)

local RenderController
local ShakerController

local Player = game.Players.LocalPlayer

local Assets = game.ReplicatedStorage.VFX.Fire.CinderCutter

function CinderCutter.Charge(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame

	local Character = casterHumanoid.Parent

	local Tool = Character:FindFirstChildWhichIsA("Tool")
	for _, Model in Tool:GetChildren() do
		if not Model:IsA("Model") then
			continue
		end

		local SwordFireEffect = Assets.Parent.SwordFireEffect:Clone()

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = Model.PrimaryPart or Model:FindFirstChildWhichIsA("BasePart", true)
		Weld.Part1 = SwordFireEffect
		Weld.Parent = SwordFireEffect

		local function getHighest(): BasePart
			local largest
			local largestSize = 0

			for _, Part: BasePart in pairs(Model:GetDescendants()) do
				if not Part:IsA("BasePart") then
					continue
				end

				local size = Part.Size.Magnitude
				if size > largestSize then
					largest = Part
					largestSize = size
				end
			end

			return largest
		end

		local part = getHighest()

		SwordFireEffect.CFrame = part:GetPivot()
		SwordFireEffect.Size = part.Size
		SwordFireEffect.Parent = part
		RenderController:EmitParticles(SwordFireEffect)

		task.delay(1.5, function()
			for i,v in ipairs(SwordFireEffect:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") then
					v.Enabled = false
				end
			end
		end)

		Debris:AddItem(SwordFireEffect, 2.5)
	end

    SFX:Create(RenderData.casterHumanoid.Parent, "DemonStep", 0 , 32)
end

local Angle = CFrame.Angles(0, 0, math.rad(25))

function CinderCutter.Attack(RenderData)
	local arguments = RenderData.arguments
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame
	local Character = casterHumanoid.Parent

    SFX:Create(Character, "ActivateFire", 0 , 32)

	RenderController:ExecuteForHumanoid(casterHumanoid, function()
		ShakerController:ShakeOnce(2, 5, 0.5, 0.5)
	end)

    local FireSpin = VFX:CreateParticle(casterRootCFrame * Angle, "FireSpin")
	TweenService:Create(FireSpin.PointLight, TweenInfo.new(0.25), {Brightness = 0}):Play()
end

function CinderCutter.Hit(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame

	local Effect = Assets.SlashHit1:Clone()
	Effect:PivotTo(casterRootCFrame * CFrame.new(0, 0, -0.5) * Angle:Inverse())
	Effect.Parent = game.Workspace
	RenderController:EmitParticles(Effect)

    SFX:Create(RenderData.casterHumanoid.Parent, "CaughtFireHit", 0 , 32)

	Debris:AddItem(Effect, 3)
end

function CinderCutter.Cancel(RenderData) end

function CinderCutter.Start()
	RenderController = Knit.GetController("RenderController")
	ShakerController = Knit.GetController("ShakerController")
end

function CinderCutter.Caller(RenderData)
	local Effect = RenderData.effect

	if CinderCutter[Effect] then
		CinderCutter[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return CinderCutter
