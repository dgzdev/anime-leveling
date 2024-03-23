local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ShakerController = Knit.GetController("ShakerController")

local LightningModule = {}

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local RocksModule = require(ReplicatedStorage.Modules.RocksModule)

local LightningBolt = require(ReplicatedStorage.Modules.LightningBolt)
local LightningSparks = require(ReplicatedStorage.Modules.LightningSparks)
local LightningExplosion = require(ReplicatedStorage.Modules.LightningExplosion)

function LightningModule.FlashStrike(RenderData: { root: BasePart })
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

	VFX:ApplyParticle(RenderData.root, "Slash", nil, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(180), 0))
	VFX:ApplyParticle(
		Root.Parent,
		"LightningSlam",
		nil,
		CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(90), 0, math.rad(90)),
		true
	)

	local pos0 = Root.CFrame.Position
	local pos1 = (Root.CFrame * CFrame.new(0, 0, -50)).Position

	local A1, A2 = {}, Root:FindFirstChildWhichIsA("Attachment")

	local cf = Root.CFrame
	local rotation = (cf - cf.Position)
	local rx, ry, rz = rotation:ToOrientation()
	local orientation = Vector3.new(math.deg(rx), math.deg(ry), math.deg(rz))

	A1.WorldPosition, A1.WorldAxis = Root.CFrame.Position, Vector3.new()

	for i = 1, 5, 1 do
		task.wait(0.1)
		local NewBolt = LightningBolt.new(A1, A2, 120)
		NewBolt.Color = Color3.new(0.474509, 0.764705, 1)
		NewBolt.CurveSize0, NewBolt.CurveSize1 = 1, 2
		NewBolt.PulseSpeed = 6
		NewBolt.AnimationSpeed = 10
		NewBolt.ColorOffsetSpeed = 6
		NewBolt.PulseLength = 0.5
		NewBolt.FadeLength = 0.25
		NewBolt.MaxRadius = 1

		LightningSparks.new(NewBolt)
	end

	VFX:ApplyParticle(Root.Parent, "Fell")
	ShakerController:Shake(ShakerController.Presets.Bump)
end

function LightningModule.LightningWave(RenderData: { root: BasePart, part: BasePart })
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

	LightningExplosion.new(
		Root.CFrame.Position,
		0.5,
		10,
		Color3.new(0.474509, 0.764705, 1),
		Color3.new(0.474509, 0.764705, 1)
	)

	VFX:ApplyParticle(Root.Parent, "Fell")
	ShakerController:Shake(ShakerController.Presets.Explosion)
end

function LightningModule.Lightning(RenderData: { root: BasePart })
	local Root = RenderData.root
	local part0 = Instance.new("Part")
	part0.Name = "Lightning"
	part0.Transparency = 1
	part0.Size = Vector3.new(1, 1, 1)
	part0.CanCollide = false
	part0.Anchored = true
	part0.CFrame = CFrame.new()
	part0.Parent = Workspace.Terrain

	part0.CFrame = CFrame.new(Root.CFrame.Position + Vector3.new(0, 30, 0))

	local A1, A2 = {}, {}
	A1.WorldPosition, A1.WorldAxis = part0.CFrame.Position, Vector3.new(0, 0, 0)
	A2.WorldPosition, A2.WorldAxis = Root.CFrame.Position, Vector3.new(0, 0, 0)
	VFX:ApplyParticle(Root.Parent, "LightningSwordHit")

	for i = 1, 5, 1 do
		task.wait(0.1)
		local NewBolt = LightningBolt.new(A1, A2, 120)
		NewBolt.Color = Color3.new(0.474509, 0.764705, 1)
		NewBolt.CurveSize0, NewBolt.CurveSize1 = 10, 15
		NewBolt.PulseSpeed = 2
		NewBolt.PulseLength = 0.5
		NewBolt.FadeLength = 0.25
		NewBolt.MaxRadius = 1

		LightningSparks.new(NewBolt)
	end

	LightningExplosion.new(
		A2.WorldPosition,
		0.5,
		10,
		Color3.new(0.474509, 0.764705, 1),
		Color3.new(0.474509, 0.764705, 1)
	)
	task.wait()
	part0:Destroy()

	RocksModule.Ground(
		A2.WorldPosition + Vector3.new(0, -5, 0),
		15,
		Vector3.new(2.5, 2.5, 2.5),
		{ Workspace.CurrentCamera, Workspace.Enemies, Workspace.NPC },
		15,
		false,
		3
	)

	ShakerController:Shake(ShakerController.Presets.Explosion)
	VFX:ApplyParticle(Root.Parent, "Fell")
end

function LightningModule.LStrike(RenderData: { root: BasePart, position: CFrame })
	local Root = RenderData.root
	local Position = RenderData.position
	RocksModule.Ground(
		Root.CFrame.Position + Vector3.new(0, -5, 0),
		15,
		Vector3.new(2.5, 2.5, 2.5),
		{ Workspace.CurrentCamera, Workspace.Enemies, Workspace.NPC },
		15,
		false,
		3
	)

	VFX:ApplyParticle(
		RenderData.root,
		"BlueSlash",
		nil,
		CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(90), 0, 0),
		false
	)

	VFX:CreateParticle(Position, "BlinkVFX", 3) --> Lines effect

	SFX:Create(Root, "YamatoSwing")

	local A1, A2 = {}, Root:FindFirstChildWhichIsA("Attachment")

	A1.WorldPosition, A1.WorldAxis = Root.CFrame.Position, Vector3.new()

	for i = 1, 5, 1 do
		task.wait(0.1)
		local NewBolt = LightningBolt.new(A1, A2, 120)
		NewBolt.Color = Color3.new(0, 0, 0)
		NewBolt.CurveSize0, NewBolt.CurveSize1 = 1, 2
		NewBolt.PulseSpeed = 6
		NewBolt.AnimationSpeed = 10
		NewBolt.ColorOffsetSpeed = 6
		NewBolt.PulseLength = 0.5
		NewBolt.FadeLength = 0.25
		NewBolt.MaxRadius = 1

		LightningSparks.new(NewBolt)
	end

	VFX:ApplyParticle(Root.Parent, "Fell")
	ShakerController:Shake(ShakerController.Presets.Bump)
end

function LightningModule.Start() end

function LightningModule.Caller(RenderData)
	if LightningModule[RenderData.effect] then
		task.spawn(LightningModule[RenderData.effect], RenderData)
	else
		print("Render not found!")
	end
end

return LightningModule
