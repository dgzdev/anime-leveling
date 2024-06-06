local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SkillService = Knit.CreateService {
    Name = "SkillService";
    Client = {};
}

--[[
	Reponsável principalmente por chamar as skills,
	Quando estiver criando uma skill que substitua o m1 do player, utilize o SetAttackOverwrite
	
	Ao iniciar uma skill crie utilize o SetSkillState para definir como Charge, assim podendo ser cancelado caso tomar um ataque,
	Caso ele receba um ataque, a skill data ficará com o estado Cancel, então antes de continuar a skill, verifique o estado dela

	após sair do estado de charge apenas altere para qualquer outro estado q vai ta td certo. Não se esqueca de limpar o estado após acabar a skill
]]

local Skills = {}
local SkillDatas = {}
local SkillThreads = {}

local WeaponService

function SkillService.UseSkill(Humanoid: Humanoid, SkillName: string, Data: {})
    if not Skills[SkillName] then
        return
    end

	SkillThreads[Humanoid] = task.spawn(function()
		Skills[SkillName].Caller(Humanoid, Data)
	end)
end


function SkillService:GetSkillsDataForHumanoid(Humanoid)
    if not SkillDatas[Humanoid] then
        SkillDatas[Humanoid] = {}
    end

    return SkillDatas[Humanoid]
end
function SkillService:GetSkillState(Humanoid, Skill)
    if not SkillDatas[Humanoid] then
        SkillDatas[Humanoid] = {}
    end

    return SkillDatas[Humanoid][Skill]
end

function SkillService:SetSkillState(Humanoid, skillName, state)
    local SkillData = SkillService:GetSkillsDataForHumanoid(Humanoid)
    SkillData[skillName] = state
    return SkillData[skillName] 
end

--skill no state Charge poderão ser canceladas
function SkillService:TryCancelSkillState(Humanoid)
    local SkillData = SkillService:GetSkillsDataForHumanoid(Humanoid)
    for skill, state in pairs(SkillData) do
        if state == "Charge" then
            SkillData[skill] = "Cancel"
			if SkillThreads[Humanoid] then
				-- não sei se vai funcionar corretamente
				task.cancel(SkillThreads[Humanoid])
				-- será necessário chamar a função de cancel da skill
			end
        end
    end
end

-- usar quando o humanoid morrer
function SkillService:ClearSkillState(Humanoid)
    if not SkillDatas[Humanoid] then return end 
    for k, v in SkillDatas[Humanoid] do
        SkillDatas[Humanoid][k] = nil
    end

    SkillDatas[Humanoid] = nil
end

function SkillService:SetAttackOverwrite(Humanoid: Humanoid, func)
   WeaponService.AttackOverwrites[Humanoid] = func
end
function SkillService:RemoveAttackOverwrite(Humanoid: Humanoid)
    WeaponService.AttackOverwrites[Humanoid] = nil
end

function SkillService.KnitInit()
    WeaponService = Knit.GetService("WeaponService")
    
    for i,v in ipairs(script:GetDescendants()) do
        if v:IsA("ModuleScript") then
            Skills[v.Name] = require(v)
        end
    end

    -- for i,v in pairs(Skills) do
    --     if v.Start then
    --         v.Start(Skills)
    --     end
    -- end
end
function SkillService.KnitStart()

end

return SkillService