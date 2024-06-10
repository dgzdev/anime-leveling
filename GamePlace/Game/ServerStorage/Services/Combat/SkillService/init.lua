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

local WeaponService
local RenderService

function SkillService:UseSkill(Humanoid: Humanoid, SkillName: string, Data: {})
	if not Skills[SkillName] then
		return
	end


	Skills[SkillName].Caller(Humanoid, Data)
end
function SkillService.Client:UseSkill(Player: Player, skillName: string, Data: {})
	local Character = Player.Character 
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	if not Humanoid then
		return
	end

	self.Server:UseSkill(Humanoid, skillName, Data)
end

function SkillService:SetSkillState(Humanoid: Humanoid, skillName: string, state: string)
	if not SkillDatas[Humanoid] then
		SkillDatas[Humanoid] = {}
	end

	SkillDatas[Humanoid][skillName] = state
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
			SkillService:SetSkillState(Humanoid, skillName, nil)

			if Skills[skillName].Cancel then
				Skills[skillName].Cancel(Humanoid)
			else
				local CancelRenderData = RenderService:CreateRenderData(Humanoid, skillName, "Cancel")
				RenderService:RenderForPlayers(CancelRenderData)
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
	RenderService = Knit.GetService("RenderService")

	for i, v in ipairs(script:GetDescendants()) do
		if v:IsA("ModuleScript") then
			Skills[v.Name] = require(v)
		end
	end

	for _, v in pairs(Skills) do
	    if v.Start then
	        v.Start(Skills)
	    end
	end
end
function SkillService.KnitStart() end

return SkillService
