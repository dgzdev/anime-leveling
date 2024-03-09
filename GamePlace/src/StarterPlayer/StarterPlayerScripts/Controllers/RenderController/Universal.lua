local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Universal = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RocksModule = require(ReplicatedStorage.Modules.RocksModule)

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ShakerController = Knit.GetController("ShakerController")


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
