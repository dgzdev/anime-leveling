local Arise = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Debris = game:GetService("Debris")
local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService
local EffectService
local RagdollService

local Validate = require(game.ReplicatedStorage.Validate)


function Arise.Charge(Humanoid, Data)
    
end


function Arise.Caller(Humanoid: Humanoid, Data: { any }, NeedWeapon)
    if Validate:CanUseSkill(Humanoid, NeedWeapon) and not DebounceService:HaveDebounce(Humanoid, "MoltenSmash") then
		Arise.Charge(Humanoid, Data)
	end
end

function Arise.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end