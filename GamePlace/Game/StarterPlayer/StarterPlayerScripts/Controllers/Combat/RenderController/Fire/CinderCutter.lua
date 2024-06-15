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

    SFX:Create(casterHumanoid.Parent, "DemonStep", 0 , 32)
end

function CinderCutter.Attack(RenderData)
	local arguments = RenderData.arguments
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame

    VFX:CreateParticle(casterRootCFrame, "FireSpin")
end

function CinderCutter.Hit(RenderData)

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
