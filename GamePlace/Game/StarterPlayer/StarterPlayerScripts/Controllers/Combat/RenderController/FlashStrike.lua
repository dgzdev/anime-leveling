local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local FlashStrike = {}

local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)

local RenderController
local ShakerController

function FlashStrike.Charge(RenderData)
	local casterHumanoid = RenderData.casterHumanoid

	RenderController:ExecuteForHumanoid(casterHumanoid, function()
		local Animation: AnimationTrack = RenderController:GetPlayingAnimationTrack(casterHumanoid, "FlashStrike")
		if not Animation then
			return
		end

		local connection
		connection = Animation:GetMarkerReachedSignal("attack"):Once(function()
			ShakerController:Shake(ShakerController.Presets.Bump)
		end)

		Animation.Ended:Once(function()
			connection:Disconnect()
		end)

		ShakerController:Shake(ShakerController.Presets.Bump2)
	end)
end

function FlashStrike.Attack(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame
	local particle = VFX:CreateParticle(
		casterRootCFrame * CFrame.new(0, 0, -20) * CFrame.Angles(0, math.rad(-90), 0),
		"FlashStrikeDash",
		1
	)
	SFX:Create(particle, "JudgeCuts", 0, 128)
end

function FlashStrike.Hit(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame
	local FlashStrikeMultipleSlashes = game.ReplicatedStorage.VFX.Sword.FlashStrike.MultipleSlashes:Clone()
	FlashStrikeMultipleSlashes:PivotTo(casterRootCFrame)
	FlashStrikeMultipleSlashes.Parent = game.Workspace
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main.Attachment)
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Stars)

	if RenderData.arguments.EmitDelayed then
		RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main.DelayedHit)
	end

	Debris:AddItem(FlashStrikeMultipleSlashes, 5)
end

function FlashStrike.Cancel(RenderData) end

function FlashStrike.Start()
	RenderController = Knit.GetController("RenderController")
	ShakerController = Knit.GetController("ShakerController")
end

function FlashStrike.Caller(RenderData)
	local Effect = RenderData.effect

	if FlashStrike[Effect] then
		FlashStrike[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return FlashStrike
