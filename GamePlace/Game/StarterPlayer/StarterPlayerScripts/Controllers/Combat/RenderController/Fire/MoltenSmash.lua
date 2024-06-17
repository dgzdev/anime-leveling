local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local MoltenSmash = {}

local TweenService = game:GetService("TweenService")
local VFX = require(game.ReplicatedStorage.Modules.VFX)
local SFX = require(game.ReplicatedStorage.Modules.SFX)
local CraterModule = require(game.ReplicatedStorage.Modules.CraterModule)

local RenderController
local ShakerController

local Player = game.Players.LocalPlayer

local Assets = game.ReplicatedStorage.VFX.Fire.MoltenSmash

function MoltenSmash.Charge(RenderData)
	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame

    SFX:Create(casterHumanoid.Parent, "DemonStep", 0 , 32)
end

function MoltenSmash.Stomp(RenderData)
	local arguments = RenderData.arguments
	local position: CFrame = arguments.position
	local size: Vector3 = arguments.size

	local casterHumanoid = RenderData.casterHumanoid
	local casterRootCFrame = RenderData.casterRootCFrame
    local Character = Player.Character

    local Explosion = Assets.Explosion:Clone()

    local ExplosionCFrame = position * CFrame.new(0, -1.5, 0)
    Explosion:PivotTo(ExplosionCFrame)
    Explosion.Parent = workspace
    RenderController:EmitParticles(Explosion)

    local Distance = (Explosion:GetPivot().Position - Character:GetPivot().Position).Magnitude
    if Distance <= 32 then
        local Magnitude = (32/Distance) / 1.5
        ShakerController:ShakeOnce(Magnitude, 10, 0.5, 0.5)
    end
    SFX:Create(Explosion, "ExplosionLight", 0 , 72)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {workspace.Characters, workspace.Enemies, workspace.Test}
    local ray = workspace:Raycast(ExplosionCFrame.Position + Vector3.new(0, 1, 0), Vector3.new(0, -3, 0), Params)
    if ray then
        local Ground = Assets.Ground:Clone()
        Ground:PivotTo(CFrame.new(ray.Position) * CFrame.new(0, -1.5, 0))
        Ground.Parent = workspace
        TweenService:Create(Ground.PointLight, TweenInfo.new(0.25), {Brightness = 0}):Play()
        TweenService:Create(Ground.Crack, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Transparency = 1}):Play()
        Debris:AddItem(Ground, 2)
    end

	CraterModule:Spawn({
		Position = Explosion:GetPivot().Position, --> Position
		AmountPerUnit = 1, --> Amount of Rocks Per Unit (1 would appear a single rock per angle step.)
		Amount = 20, --> Amount of rocks that will exist in the circle. (360 / Amount)
		Angle = {10, 30}, --> Random Angles (Y) axis.
		Radius = {6, 7}, --> Random Radius;
		Size = {2.5, 3}, --> Random Size (number only);

		Offset = {
			X = 0,
			Y = 0.5,
			Z = 0,
		}, --> Random offset (Y);

		DespawnTime = 2, --> Despawn Time
	})

    CraterModule:ExplosionRocks({
		Position = ExplosionCFrame.Position, --> Position;
		Amount = 10, --> Amount of Rocks;
		Radius = {
			X = 2,
			Y = -2,
			Z = 2,
		},
		Size = {Vector3.one, Vector3.one},
		Force = {
			X = {-45, 45},
			Y = {30, 50},
			Z = {-45, 45},
		},

		DebrisTemplate = game.ReplicatedStorage.VFX.Debris.OnFire,
		Trail = true, --> Enable / Disable
		Direction = casterRootCFrame, --> Direction (Gets 'LookVector', 'UpVector' and 'RightVector' automatically)
		DespawnTime = 1, --> Despawn Time.
	})


    Debris:AddItem(Explosion, 5)
end

function MoltenSmash.Hit(RenderData)
	local casterRootCFrame = RenderData.casterRootCFrame
	local FlashStrikeMultipleSlashes = game.ReplicatedStorage.VFX.Sword.FlashStrike.MultipleSlashes:Clone()
	FlashStrikeMultipleSlashes:PivotTo(casterRootCFrame)
	FlashStrikeMultipleSlashes.Parent = game.Workspace
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main.Attachment)
	RenderController:EmitParticles(FlashStrikeMultipleSlashes.Stars)

	if RenderData.arguments.EmitDelayed then
		RenderController:EmitParticles(FlashStrikeMultipleSlashes.Main.DelayedHit)
	end

	Debris:AddItem(FlashStrikeMultipleSlashes, 5)
end

function MoltenSmash.Cancel(RenderData) end

function MoltenSmash.Start()
	RenderController = Knit.GetController("RenderController")
	ShakerController = Knit.GetController("ShakerController")
end

function MoltenSmash.Caller(RenderData)
	local Effect = RenderData.effect

	if MoltenSmash[Effect] then
		MoltenSmash[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return MoltenSmash
