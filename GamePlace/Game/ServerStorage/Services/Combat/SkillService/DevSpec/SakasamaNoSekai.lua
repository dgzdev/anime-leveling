local SakasamaNoSekai = {}
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

local Cooldown = 180
function SakasamaNoSekai.Charge(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    DebounceService:AddDebounce(Humanoid, "SakasamaNoSekai", Cooldown, true)
	SkillService:SetSkillState(Humanoid, "SakasamaNoSekai", "Charge")

    local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "SakasamaNoSekai", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

    DebounceService:AddDebounce(Humanoid, "UsingSkill", 4)
    WeaponService:Stun(Humanoid.Parent, 4)
    task.wait(1)
    SakasamaNoSekai.Activate(Humanoid, Data)
end

function SakasamaNoSekai.Activate(Humanoid: Humanoid, Data: { CasterCFrame: CFrame })
    local RootPart = Humanoid.RootPart
    local state = SkillService:GetSkillState(Humanoid, "SakasamaNoSekai")
    if state == nil then
        return
    end
    SkillService:SetSkillState(Humanoid, "SakasamaNoSekai", "Activate")

    local CharactersInArea = HitboxService:GetCharactersInCircleArea(RootPart.CFrame.Position, 25)

    local Affected = {}
    for _, Character in CharactersInArea do
        -- if Character == Humanoid.Parent then
        --     continue
        -- end
        local Player = game.Players:GetPlayerFromCharacter(Character)
        if Player then
            table.insert(Affected, Player) 
        end
    end 

    local RenderData = RenderService:CreateRenderData(Humanoid, "SakasamaNoSekai", "UpsideDown")
    RenderService:RenderForPlayers(RenderData, Affected)
end

function SakasamaNoSekai.Cancel(Humanoid: Humanoid)
    DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
end
--------
function SakasamaNoSekai.Caller(Humanoid: Humanoid, Data: { any })
    if Validate:CanUseSkill(Humanoid, true) and not DebounceService:HaveDebounce(Humanoid, "SakasamaNoSekai") then
		SakasamaNoSekai.Charge(Humanoid, Data)
	end
end

function SakasamaNoSekai.Start()
    EffectService = Knit.GetService("EffectService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
    RagdollService = Knit.GetService("RagdollService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return SakasamaNoSekai