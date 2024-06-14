local Arise = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService
local EffectService
local RagdollService
local AriseService
local EnemyService

local Validate = require(game.ReplicatedStorage.Validate)

function Arise.SetSoul(TargetHumanoid, Player)

end


function Arise.Charge(Humanoid: Humanoid, Data: { any })
	Arise.Use(Humanoid, Data)
	--aplicar o debounce,
    -- setar o skill state para Charge,
	-- stunnar o Humanoid se necessário
	--esperar um tempo de charge
	-- chamar o Use
end

function Arise.Use(Humanoid: Humanoid, Data: { any })
	local Player = Players:FindFirstChild(Humanoid.Parent.Name)
	local HumanoidsAvailable = AriseService:GetPossessionAvailable(Player)

	local CharPlayer = Player.Character

	print(HumanoidsAvailable)
	if not HumanoidsAvailable then return end
	for i,v : Humanoid in pairs(HumanoidsAvailable) do
		print(math.abs((v.Parent.Torso.Position - CharPlayer.PrimaryPart.Position).Magnitude))
		if math.abs((v.Parent.Torso.Position - CharPlayer.PrimaryPart.Position).Magnitude) < 5 then

			local TestModel : Model = ReplicatedStorage.Models.Test:Clone()

			TestModel.Parent = workspace.Test
			TestModel:PivotTo(v.Parent.Torso.CFrame)

			AriseService:RemovePossession(Player, v)

			task.wait(.1)
			EnemyService:CreateEnemy(TestModel)


	

			v.Parent:Destroy()
		end
	end
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
	AriseService = Knit.GetService("AriseService")
	EnemyService = Knit.GetService("EnemyService")
end


return Arise