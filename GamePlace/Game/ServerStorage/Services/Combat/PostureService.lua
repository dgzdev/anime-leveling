local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PostureService = Knit.CreateService({
	Name = "PostureService",
	Client = {},
})

local CombatService
local CharacterService
local RenderService
local AnimationService

function PostureService:PostureBreak(Humanoid: Humanoid)
	if Humanoid:GetAttribute("PostureBreak") then
		return
	end

	AnimationService:StopAnimationMatch(Humanoid, "Block")
	Humanoid:SetAttribute("PostureBreak", true)
	Humanoid:SetAttribute("Block", false)
	Humanoid:SetAttribute("Posture", 0)

	CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

	local PostureBreakRenderData = RenderService:CreateRenderData(Humanoid, "HitEffects", "PostureBreak")
	RenderService:RenderForPlayers(PostureBreakRenderData)

	task.delay(2, function()
		Humanoid:SetAttribute("PostureBreak", false)
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
	end)
end

function PostureService:AddPostureDamage(Humanoid: Humanoid, HumanoidWhoHitted: Humanoid, Amount: number, ByDeflect: boolean?)
	local ByDeflect = ByDeflect or false
	local DamageClap = math.clamp(Amount, 0, Humanoid:GetAttribute("MaxPosture") - Humanoid:GetAttribute("Posture"))
	Humanoid:SetAttribute("Posture", Humanoid:GetAttribute("Posture") + DamageClap)

	if not ByDeflect then
		if
			Humanoid:GetAttribute("Posture") >= Humanoid:GetAttribute("MaxPosture")
			and not Humanoid:GetAttribute("PostureBreak")
		then
			HumanoidWhoHitted:SetAttribute("ComboCounter", 0)
			PostureService:PostureBreak(Humanoid)
		end
	end
end

function PostureService:RemovePostureDamage(Humanoid: Humanoid, Recover: number)
	local DamageClamp = math.clamp(Recover, 0, Humanoid:GetAttribute("Posture"))
	Humanoid:SetAttribute("Posture", Humanoid:GetAttribute("Posture") - DamageClamp)
end

function PostureService.KnitInit()
	AnimationService = Knit.GetService("AnimationService")
	CombatService = Knit.GetService("CombatService")
	RenderService = Knit.GetService("RenderService")
	CharacterService = Knit.GetService("CharacterService")
end

return PostureService
