local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Universal = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RocksModule = require(ReplicatedStorage.Packages.RocksModule)

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

function Universal.Start() end

function Universal.Caller(RenderData)
	if Universal[RenderData.effect] then
		task.spawn(Universal[RenderData.effect], RenderData)
	else
		print("Render not found!")
	end
end

return Universal
