local CinderCutter = {}

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

local Cooldown = 0
function CinderCutter.Charge(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    DebounceService:AddDebounce(Humanoid, "CinderCutter", Cooldown, false)
	SkillService:SetSkillState(Humanoid, "CinderCutter", "Charge")

    local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "CinderCutter", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

    DebounceService:AddDebounce(Humanoid, "UsingSkill", 0.5)
    WeaponService:Stun(Humanoid.Parent, Data.CasterCFrame.Position, 0.5)

    task.wait(0.5)
    CinderCutter.Attack(Humanoid, Data)
end

function CinderCutter.Attack(Humanoid: Humanoid, Data: { any })
    local state = SkillService:GetSkillState(Humanoid, "CinderCutter")
	if state == nil then
		return
	end
    
    local RootPart = Humanoid.RootPart
	local Damage = Data.Damage or 15
    SkillService:SetSkillState(Humanoid, "CinderCutter", "Attack")

	DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
    local AttackRenderData = RenderService:CreateRenderData(Humanoid, "CinderCutter", "Attack")
	RenderService:RenderForPlayers(AttackRenderData)

    local Characters = HitboxService:GetCharactersInCircleArea(Data.CasterCFrame.Position, 10)
    for _, Enemy in Characters do
        if Enemy == Humanoid.Parent then
            continue
        end

        DamageService:Hit(Enemy.Humanoid, Humanoid, Damage)
    end
end

function CinderCutter.Cancel(Humanoid: Humanoid)
    DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
end
--------
function CinderCutter.Caller(Humanoid: Humanoid, Data: { any })
    if Validate:CanUseSkill(Humanoid, false) and not DebounceService:HaveDebounce(Humanoid, "CinderCutter") then
		CinderCutter.Charge(Humanoid, Data)
	end
end

function CinderCutter.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return CinderCutter