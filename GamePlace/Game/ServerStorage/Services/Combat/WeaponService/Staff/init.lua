local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService
local RagdollService

local Validate = require(game.ReplicatedStorage.Validate)
local FastCast = require(game.ReplicatedStorage.Modules.FastCastRedux)

local Default

local function DestroyBullet(Bullet)
	for i, v in Bullet:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end

	local PointLight = Bullet:FindFirstChildWhichIsA("PointLight")
	if PointLight then
		TweenService:Create(PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Brightness = 0}):Play()
	end
	Debris:AddItem(Bullet, 0.5)
end

Staff = {
	Attack = function(Character, Data)
        local Humanoid = Character.Humanoid
		local CasterCFrame = Data.CasterCFrame* CFrame.new(1.5, 0, 0)
		local Tool = HotbarService:GetEquippedTool(Character)

		if not Tool then
			return
		end
		if not Validate:CanAttack(Humanoid) then
			return
		end

		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")

		local AnimationPath: Animation = AnimationsFolder.Hit[Counter]
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()

		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.3
		DebounceService:AddDebounce(Humanoid, "AttackCombo", SwingSpeed + 0.15)
		DebounceService:AddDebounce(Humanoid, "AttackDebounce", SwingSpeed)
		Humanoid:SetAttribute("LastAttackTick", tick())

		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local Damage = Tool:GetAttribute("Damage") or 5
		local HitEffect = Tool:GetAttribute("HitEffect") or Tool:GetAttribute("Type")
		local Markers = AnimationService:GetAllAnimationEventNames(AnimationPath.AnimationId)

		local Caster = FastCast.new()
		local Origin = (CasterCFrame * CFrame.new(0, 0, -3)).Position
		local Direction = CasterCFrame.LookVector
		local Variant = 75
		local Behavior = FastCast.newBehavior()

		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {Character} -- pensar em aliados
		Behavior.RaycastParams = Params
		Behavior.AutoIgnoreContainer = true
		Behavior.CosmeticBulletTemplate  = game.ReplicatedStorage.VFX.Staff.MageM1
		Behavior.CosmeticBulletContainer = workspace.CastContainer
		Behavior.MaxDistance = 60

		local Overlap = OverlapParams.new()
		Overlap.FilterType = Enum.RaycastFilterType.Exclude
		Overlap.FilterDescendantsInstances = {Character}

		local activeCast = Caster:Fire(Origin, Direction, Variant, Behavior)
		Caster.LengthChanged:Connect(function(activeCast, LastPoint, RayDir, Displacement, Velocity, CosmeticBullet)
			local NewPosition = LastPoint + (RayDir * Displacement)
			CosmeticBullet:PivotTo(CFrame.new(NewPosition))
			
			local enemies = HitboxService:GetCharactersInCircleArea(NewPosition, 1.5, Overlap)
			for _, Enemy in enemies do
				DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
				WeaponService:TriggerHittedEvent(Enemy.Humanoid, Humanoid)
				DamageService:TryHit(Enemy.Humanoid, Humanoid, Damage, "ManaStaff", false)
			end

			if #enemies > 0 then
				activeCast:Terminate()					
			end
		end)

		Caster.RayHit:Connect(function(Caster, Result, Velocity, CosmeticBullet)
			DestroyBullet(CosmeticBullet)
		end)

		Caster.CastTerminating:Connect(function(Caster)
			local Bullet = Caster.RayInfo.CosmeticBulletObject
			if Bullet then
				DestroyBullet(Bullet)
			end
		end)

		WeaponService:IncreaseComboCounter(Humanoid)
		task.delay(SwingSpeed + 0.15, function()
			CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
		end)
	end,

	StrongAttack = function(...)
		Default.StrongAttack(...)
	end,
}

function Staff.Start(default)
	local CastContainer = Instance.new("Folder")
	CastContainer.Name = "CastContainer"
	CastContainer.Parent = game.Workspace

	Default = default
    RagdollService = Knit.GetService("RagdollService")
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	AnimationService = Knit.GetService("AnimationService")
end

return Staff
