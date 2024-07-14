local HealingCircle = {}
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

local Cooldown = 1
function HealingCircle.Charge(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    DebounceService:AddDebounce(Humanoid, "HealingCircle", Cooldown, true)

    DebounceService:AddDebounce(Humanoid, "UsingSkill", 1)
    DebounceService:AddDebounce(Humanoid, "IFrame", 1)
    SkillService:SetSkillState(Humanoid, "HealingCircle", "Charge")

    HealingCircle.Activate(Humanoid, Data)
end

function HealingCircle.Activate(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    if not SkillService:GetSkillState(Humanoid, "HealingCircle") then
        return 
    end

    local RootPart = Humanoid.RootPart
    SkillService:SetSkillState(Humanoid, "HealingCircle", "Activate")
    local ActivateRenderData = RenderService:CreateRenderData(Humanoid, "HealingCircle", "Activate")
    RenderService:RenderForPlayersInRadius(ActivateRenderData, RootPart.CFrame.Position, 150)

    local CharactersInArea = HitboxService:GetCharactersInCircleArea(RootPart.CFrame.Position, 12.5)

    for _, Char in CharactersInArea do
        local CharHumanoid: Humanoid = Char:FindFirstChild("Humanoid")
        if not CharHumanoid then
            continue
        end

        EffectService:AddEffect(CharHumanoid, "HealingCircle", "HealthRegeneration", 2.5, "%", 10)
    end

    task.wait(10)

    SkillService:SetSkillState(Humanoid, "HealingCircle", nil)
end

function HealingCircle.Cancel(Humanoid: Humanoid)
    DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
end
--------
function HealingCircle.Caller(Humanoid: Humanoid, Data: { any })
    if Validate:CanUseSkill(Humanoid, true) and not DebounceService:HaveDebounce(Humanoid, "HealingCircle") then
		HealingCircle.Charge(Humanoid, Data)
	end
end

function HealingCircle.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return HealingCircle