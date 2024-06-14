local MoltenSmash = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService
local EffectService
local RagdollService


local Validate = require(game.ReplicatedStorage.Validate)

local Cooldown = 5
function MoltenSmash.Charge(Humanoid: Humanoid, Data: { any })
    DebounceService:AddDebounce(Humanoid, "MoltenSmash", Cooldown, false)
	SkillService:SetSkillState(Humanoid, "MoltenSmash", "Charge")

    local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "MoltenSmash", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)
    DebounceService:AddDebounce(Humanoid, "UsingSkill", 0.85)
    WeaponService:Stun(Humanoid.Parent, Humanoid.RootPart:GetPivot().Position, 0.85)
    task.wait(0.5)
    MoltenSmash.Stomp(Humanoid, Data)
end

function MoltenSmash.Stomp(Humanoid: Humanoid, Data: { any })
    local RootPart = Humanoid.RootPart
    local state = SkillService:GetSkillState(Humanoid, "MoltenSmash")
    SkillService:SetSkillState(Humanoid, "MoltenSmash", "Stomp")

	local Damage = Data.Damage or 15
	if state == nil then
		return
	end

    local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "MoltenSmash", "Stomp")
	RenderService:RenderForPlayers(ChargeRenderData)

	DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
    HitboxService:CreateFixedHitbox(RootPart.CFrame * CFrame.new(0, 0, -3), Vector3.new(8, 8, 8), 1, function(Enemy)
        if Enemy == RootPart.Parent then
            return
        end

        EffectService:AddEffect(Enemy.Humanoid, "MoltenSmashBurn", "Burn", 3, "int", 5)
        RagdollService:Ragdoll(Enemy, 1.25)
        Enemy.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 180, 0)
        DamageService:Hit(Enemy.Humanoid, Humanoid, Damage)
    end)
end

function MoltenSmash.Cancel(Humanoid: Humanoid)
    DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
end
--------
function MoltenSmash.Caller(Humanoid: Humanoid, Data: { any }, NeedWeapon)
    if Validate:CanUseSkill(Humanoid, NeedWeapon) and not DebounceService:HaveDebounce(Humanoid, "MoltenSmash") then
		MoltenSmash.Charge(Humanoid, Data)
	end
end

function MoltenSmash.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return MoltenSmash