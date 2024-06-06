local Knit = require(game.ReplicatedStorage.Packages.Knit)

local AnimationService = Knit.CreateService({
    Name = "AnimationService",
})


function AnimationService:StopAnimationMatch(Humanoid:Humanoid, pattern: string)
	if not pattern then return end
    local Animator: Animator = Humanoid.Animator

	for _, anim: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
		if anim.Name:find(pattern) then
			anim:Stop()
		end
	end
end

function AnimationService:StopM1Animation(Humanoid:Humanoid)
    local Animator: Animator = Humanoid.Animator

	for _, anim: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
		if anim.Name:find("M1_") then
			anim:Stop()
		end
	end
end

function AnimationService.KnitInit()
    
end