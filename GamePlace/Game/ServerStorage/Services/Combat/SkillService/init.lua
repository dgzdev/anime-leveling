local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SkillService = Knit.CreateService({
	Name = "SkillService",
	Client = {},
})

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

function SkillService:SetSkillState(Humanoid: Humanoid, skillName: string, state: string)
	local SkillData = SkillService:GetSkillState(Humanoid)
	SkillData[skillName] = state
	return SkillData[skillName]
end

function SkillService:GetSkillsStates(Humanoid: Humanoid)
	if not SkillDatas[Humanoid] then
		SkillDatas[Humanoid] = {}
	end

	return SkillDatas[Humanoid]
end

function SkillService:GetSkillState(Humanoid: Humanoid, skillName: string)
	if not SkillDatas[Humanoid] then
		SkillDatas[Humanoid] = {}
	end

	return SkillDatas[Humanoid][skillName]
end

--skill no state Charge poderão ser canceladas
function SkillService:TryCancelSkillsStates(Humanoid: Humanoid)
	local SkillDatas = SkillService:GetSkillsStates(Humanoid)
	for skillName, state in SkillDatas do
		if state == "Charge" then
			SkillDatas[skillName] = "Cancel"
			if SkillThreads[Humanoid] then
				task.cancel(SkillThreads[Humanoid])
			end
			if Skills[skillName].Cancel then
				Skills[skillName].Cancel(Humanoid)
			end
		end
	end
end

-- usar quando o humanoid morrer
function SkillService:ClearSkillStates(Humanoid: Humanoid)
	if not SkillDatas[Humanoid] then
		return
	end
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

	for i, v in ipairs(script:GetDescendants()) do
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
function SkillService.KnitStart() end

return SkillService
