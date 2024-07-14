local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HealingCircle = {}

local TweenService = game:GetService("TweenService")
local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)
local CraterModule = require(game.ReplicatedStorage.Modules.CraterModule)

local RenderController
local ShakerController

local Player = game.Players.LocalPlayer

local HealingCircleAssets = game.ReplicatedStorage.VFX.Heal.HealingCircle

function HealingCircle.Activate(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame

	local Character = casterHumanoid.Parent

    local Effect = HealingCircleAssets.HealingCircleEffect:Clone()
    Effect:PivotTo(casterRootCFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90)))
    Effect.Parent = workspace
    RenderController:EmitParticles(Effect)
    task.wait(10)
    for i,v in ipairs(Effect:GetDescendants()) do
        if v:IsA("ParticleEmitter") then
            v.Enabled = false
        end
    end 
    Debris:AddItem(Effect, 5)

end

function HealingCircle.Start()
	RenderController = Knit.GetController("RenderController")
	ShakerController = Knit.GetController("ShakerController")
end

function HealingCircle.Caller(RenderData)
	local Effect = RenderData.effect

	if HealingCircle[Effect] then
		HealingCircle[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return HealingCircle
