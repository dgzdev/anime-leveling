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

    SFX:Create(RenderData.casterHumanoid.Parent, "DemonStep", 0 , 32)
end

local Angle = CFrame.Angles(0, 0, math.rad(25))

function CinderCutter.Attack(RenderData)
	local arguments = RenderData.arguments
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame

    SFX:Create(casterHumanoid.Parent, "ActivateFire", 0 , 32)

    local FireSpin = VFX:CreateParticle(casterRootCFrame * Angle, "FireSpin")
	TweenService:Create(FireSpin.PointLight, TweenInfo.new(0.25), {Brightness = 0}):Play()
end

function CinderCutter.Hit(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame

	local Effect = Assets.SlashHit1:Clone()
	Effect:PivotTo(casterRootCFrame * CFrame.new(0, 0, -0.5))
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
