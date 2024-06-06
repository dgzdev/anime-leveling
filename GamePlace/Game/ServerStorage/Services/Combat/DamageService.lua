local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DamageService = Knit.CreateService {
    Name = "DamageService"
}

local DebounceService
local SkillService
local PostureService
local AnimationService
local RenderService

function DamageService:DealDamage(HumanoidToDamage: Humanoid, Damage: number, Humanoid: Humanoid?)
	if HumanoidToDamage.Health - 1 < 0 then return end
	local DamageClamp = math.clamp(Damage, 0, HumanoidToDamage.Health - 1)
	HumanoidToDamage:TakeDamage(DamageClamp)
end

-- força um hit, ignorando o block
function DamageService:Hit(HumanoidHitted: Humanoid, Humanoid: Humanoid, Damage: number, HitEffect: string?)
	HumanoidHitted:SetAttribute("Running", false)
	DebounceService:AddDebounce(HumanoidHitted, "Hit", 1, true)
	DamageService:DealDamage(HumanoidHitted, Damage, Humanoid)
	SkillService:TryCancelSkillData(HumanoidHitted)

	PostureService:RemovePostureDamage(Humanoid, Damage / 2.5)

	if HumanoidHitted:GetAttribute("HitCounter") == 4 then
		HumanoidHitted:SetAttribute("HitCounter", 0)
	end

	HumanoidHitted:SetAttribute("HitCounter", math.clamp((HumanoidHitted:GetAttribute("HitCounter") or 1) + 1, 0, 4))
	Humanoid:SetAttribute("HitCounter", 1)
	
	AnimationService:StopM1Animation(HumanoidHitted)
	{
		-- if not HumanoidHitted:GetAttribute("Ragdoll") then
		-- 	if Humanoid:GetAttribute("AttackDirection") == "Left" then
		-- 		HumanoidHitted.Animator:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Weapons.Fists.HittedL):Play()
		-- 	else 
		-- 		HumanoidHitted.Animator:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Weapons.Fists.HittedR):Play()
		-- 	end
		-- end
	}

	local hitEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", HitEffect or "Default")
	RenderService:RenderForPlayers(hitEffectRenderData)
end



-- retorna a ação que aconteceria caso um humanoid caso seja atacado
function DamageService:GetHitContext(HumanoidHitted: Humanoid)
	if HumanoidHitted:GetAttribute("DeflectTime") then
		return "Deflect"
	else
		if HumanoidHitted:GetAttribute("Block") then
			return "Block"
		else -- if HumanoidHitted:GetAttribute("RollIFrame") then
			-- 	return "Dodge"
			-- else
			return "Hit"
		end
	end
end

function DamageService.KnitInit()
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
	PostureService = Knit.GetService("PostureService")
	AnimationService = Knit.GetService("AnimationService")
	RenderService = Knit.GetService("RenderService")
end

return DamageService