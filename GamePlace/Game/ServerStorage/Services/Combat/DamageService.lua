local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DamageService = Knit.CreateService({
	Name = "DamageService",
})

local DebounceService
local SkillService
local PostureService
local AnimationService
local RenderService
local CharacterService

function DamageService:DealDamage(HumanoidToDamage: Humanoid, Damage: number, Humanoid: Humanoid?)
	if HumanoidToDamage.Health - 1 < 0 then
		return
	end
	local DamageClamp = math.clamp(Damage, 0, HumanoidToDamage.Health - 1)
	HumanoidToDamage:TakeDamage(DamageClamp)
end

-- força um hit, ignorando o block
function DamageService:Hit(HumanoidHitted: Humanoid, Humanoid: Humanoid, Damage: number, HitEffect: string?)
	HumanoidHitted:SetAttribute("Running", false)
	DebounceService:AddDebounce(HumanoidHitted, "Hit", 1, true)
	DamageService:DealDamage(HumanoidHitted, Damage, Humanoid)
	SkillService:TryCancelSkillsStates(HumanoidHitted)

	PostureService:RemovePostureDamage(Humanoid, Damage / 2.5)

	if HumanoidHitted:GetAttribute("HitCounter") == 4 then
		HumanoidHitted:SetAttribute("HitCounter", 0)
	end

	HumanoidHitted:SetAttribute("HitCounter", math.clamp((HumanoidHitted:GetAttribute("HitCounter") or 1) + 1, 0, 4))
	Humanoid:SetAttribute("HitCounter", 1)

	AnimationService:StopM1Animation(HumanoidHitted)

	local hitEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", HitEffect or "Default")
	RenderService:RenderForPlayers(hitEffectRenderData)
end

-- função hit, possui verificações de block e dodge, além de aplicar debuffs de hit
function DamageService:TryHit(Humanoid: Humanoid, HumanoidHitted: Humanoid, _Damage: number, HitEffect: string?)
	if HumanoidHitted == nil then
		return
	end

	CharacterService:UpdateWalkSpeedAndJumpPower(HumanoidHitted)

	if _Damage == nil then
		return print("Damage is nil")
	end

	local Damage = _Damage
	local DeflectPostureDamage
	local BlockPostureDamage

	if typeof(Damage) == "table" then
		if Damage.Damage == nil then
			print("Table damage is nil")
			return
		end
		if Damage.Block == nil then
			print("Table block is nil")
			return
		end
		if Damage.Deflect == nil then
			print("Table deflect is nil")
			return
		end

		Damage = _Damage.Damage
		DeflectPostureDamage = _Damage.Deflect
		BlockPostureDamage = _Damage.Block
	elseif typeof(Damage) == "number" then
		DeflectPostureDamage = Damage
		BlockPostureDamage = Damage * 1.2
	end

	if HumanoidHitted:GetAttribute("DeflectTime") then
		HumanoidHitted:SetAttribute("HitCounter", 0)
		DebounceService:AddDebounce(HumanoidHitted, "DeflectTime", 0.125, true)
		PostureService:RemovePostureDamage(HumanoidHitted, 10)
		Humanoid:SetAttribute("Deflected", true)
		PostureService:AddPostureDamage(Humanoid, DeflectPostureDamage, true)
		DebounceService:RemoveDebounce(HumanoidHitted, "Hit")
		DebounceService:RemoveDebounce(HumanoidHitted, "Blocked")
		Humanoid:SetAttribute("ComboCounter", 1)
		HumanoidHitted:SetAttribute("BlockEndLag", false)

		AnimationService:StopM1Animation(Humanoid)

		-- if Humanoid:GetAttribute("AttackDirection") == "Left" then
		-- 	Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Weapons.General.DeflectedL):Play()
		-- else
		-- 	Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Weapons.General.DeflectedR):Play()
		-- end

		-- local AnimationFolder = CharacterService:GetReplicatedAnimationFolder(HumanoidHitted.Parent)
		-- if AnimationFolder then
		-- 	HumanoidHitted.Animator:LoadAnimation(AnimationFolder.BlockHit):Play()
		-- end

		task.delay(1, function()
			Humanoid:SetAttribute("Deflected", false)
		end)

		task.spawn(function()
			local deflectEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", "Deflect")
			RenderService:RenderForPlayers(deflectEffectRenderData)
		end)
		return false
	else
		if HumanoidHitted:GetAttribute("Block") then
			HumanoidHitted:SetAttribute("HitCounter", 0)
			-- local ReplicatedAnimations = CharacterService:GetReplicatedAnimationFolder(HumanoidHitted.Parent)
			-- if ReplicatedAnimations then
			-- 	local BlockHit = HumanoidHitted.Animator:LoadAnimation(ReplicatedAnimations.BlockHit):: AnimationTrack
			-- 	BlockHit.Priority = Enum.AnimationPriority.Action2
			-- 	BlockHit:Play()
			-- end

			DebounceService:AddDebounce(HumanoidHitted, "Blocked", 0.5, true)
			PostureService:AddPostureDamage(HumanoidHitted, BlockPostureDamage)

			local blockEffectRenderData = RenderService:CreateRenderData(HumanoidHitted, "HitEffects", "Blocked")
			RenderService:RenderForPlayers(blockEffectRenderData)
			return false
		else
			DamageService:Hit(HumanoidHitted, Humanoid, Damage, HitEffect)
		end
	end

	CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
	CharacterService:UpdateWalkSpeedAndJumpPower(HumanoidHitted)
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
	CharacterService = Knit.GetService("CharacterService")
end

return DamageService
