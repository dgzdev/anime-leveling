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


function Arise.Charge(Humanoid: Humanoid, Data: { any })
	--aplicar o debounce,
    -- setar o skill state para Charge,
	-- stunnar o Humanoid se necessário
	--esperar um tempo de charge
	-- chamar o Attack
end

function Arise.Attack(Humanoid: Humanoid, Data: { any })
	-- verifica se o skill state não é nil
	-- logica da skill

	-- para renderizar utilize o RenderService e o RenderController no PlayerScripts
end

-- caso a skill for cancelada no Charge, coloque o que deve ocorrer aqui
-- function Arise.Cancel(Humanoid: Humanoid, Data: { any })
	
-- end


function Arise.Caller(Humanoid: Humanoid, Data: { any })
    if Validate:CanUseSkill(Humanoid, false) and not DebounceService:HaveDebounce(Humanoid, "Arise") then
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


return Arise