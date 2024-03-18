local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Universal = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RocksModule = require(ReplicatedStorage.Modules.RocksModule)

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ShakerController = Knit.GetController("ShakerController")


function Universal.VenomDash(RenderData: {root: BasePart, position: CFrame})
	local Root = RenderData.root

	VFX:CreateParticle(RenderData.position * CFrame.new(0,0,-15), "VenomDash", 3)
	ShakerController:Shake(ShakerController.Presets.Bump)
end

function Universal.VenomSlashes(RenderData: {root: BasePart, position: CFrame})
	local Root = RenderData.root

	--> Define os valores mínimos e máximos
	local min = -60
	local max = 60

	--> Gera um número aleatório entre 0 e 1
	local random = math.random()

	--> Se o número aleatório for menor ou igual a 0.5, retorna o valor mínimo, caso contrário, retorna o valor máximo
	local absoluteRandom = (random <= 0.5) and min or max
	
	VFX:ApplyParticle(Root.Parent,"BlueSlash1",.2,CFrame.Angles(-36,absoluteRandom,0),false)
	ShakerController:Shake(ShakerController.Presets.Bump)
end



function Universal.VenomPalm(RenderData: {root: BasePart, position: CFrame})
	local Root = RenderData.root

	VFX:ApplyParticle(Root.Parent,"VenomPalm",3,nil,true)
	VFX:CreateParticle(RenderData.position, "darkCuts", 3)

	ShakerController:Shake(ShakerController.Presets.Bump)
end

function Universal.FlashStrike(RenderData: { root: BasePart })
	local Root = RenderData.root

	RocksModule.Ground(
		Root.CFrame.Position + Vector3.new(0, -5, 0),
		15,
		Vector3.new(2.5, 2.5, 2.5),
		{ Workspace.CurrentCamera, Workspace.Enemies, Workspace.NPC },
		15,
		false,
		3
	)

	VFX:ApplyParticle(Root.Parent, "Fell")
end

function Universal.Replicate(RenderData: {
	VFX: string?,
	SFX: string?,
	root: BasePart,
})
	if RenderData.VFX then
		VFX:ApplyParticle(RenderData.root, RenderData.VFX)
	end
	if RenderData.SFX then
		SFX:Apply(RenderData.root, RenderData.SFX)
	end
end

function Universal.Start() end

function Universal.Caller(RenderData)
	if Universal[RenderData.effect] then
		task.spawn(Universal[RenderData.effect], RenderData)
	else
		error("Render not found!")
	end
end

return Universal
