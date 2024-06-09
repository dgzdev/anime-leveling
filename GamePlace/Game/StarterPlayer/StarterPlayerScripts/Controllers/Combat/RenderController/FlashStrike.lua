local Knit = require(game.ReplicatedStorage.Packages.Knit)
local FlashStrike = {}

local VFX = require(game.ReplicatedStorage.Modules.VFX)

local RenderController
local ShakerController

function FlashStrike.Charge(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRoot: BasePart = casterHumanoid.RootPart

	local Animation: AnimationTrack = casterHumanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.Skills.FlashStrike.FlashStrikeAttack)
	Animation.Priority = Enum.AnimationPriority.Action
	Animation:Play()

	local connection
	connection = Animation:GetMarkerReachedSignal("attack"):Once(function()
		ShakerController:Shake(ShakerController.Presets.Bump)
	end)

	Animation.Ended:Once(function()
		connection:Disconnect()
	end)

	ShakerController:Shake(ShakerController.Presets.Bump2)
end

function FlashStrike.Attack(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame
	VFX:CreateParticle(casterRootCFrame * CFrame.new(0,0,-13) * CFrame.Angles(0,math.rad(-90),0), "FlashStrike", 1)
end

function FlashStrike.Cancel(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	RenderController:StopPlayingMatchAnimation(casterHumanoid, "FlashStrikeAttack", 0.45)
end

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
