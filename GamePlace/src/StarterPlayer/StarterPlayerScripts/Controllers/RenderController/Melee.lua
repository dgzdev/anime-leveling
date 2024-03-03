local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Melee = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RocksModule = require(ReplicatedStorage.Modules.RocksModule)

function Melee.GroundSlam(RenderData: { root: BasePart })
	RocksModule.Ground(
		RenderData.root.CFrame.Position + Vector3.new(0, -5, 0),
		15,
		Vector3.new(2.5, 2.5, 2.5),
		{ Workspace.CurrentCamera, Workspace.Enemies, Workspace.NPC },
		15,
		false,
		3
	)

	VFX:ApplyParticle(RenderData.root, "GroundSlam", 2, CFrame.new(0, -2.6, 0) * CFrame.Angles(math.rad(90), 0, 0))
end

function Melee.StrongPunch(RenderData: { root: BasePart }) end

function Melee.Start() end

function Melee.Caller(RenderData)
	if Melee[RenderData.effect] then
		task.spawn(Melee[RenderData.effect], RenderData)
	else
		error("Render not found!")
	end
end

return Melee
