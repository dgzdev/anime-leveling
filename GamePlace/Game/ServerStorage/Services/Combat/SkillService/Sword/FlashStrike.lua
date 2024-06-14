local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService
local AnimationService

local Validate = require(game.ReplicatedStorage.Validate)

local FlashStrike = {}

local Cooldown = 0
function FlashStrike.Charge(Humanoid: Humanoid, Data: { any })
	DebounceService:AddDebounce(Humanoid, "FlashStrike", Cooldown, false)
	SkillService:SetSkillState(Humanoid, "FlashStrike", "Charge")

	local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

	local Animation: AnimationTrack =
	Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.Skills.FlashStrike.FlashStrikeAttack)
	Animation.Priority = Enum.AnimationPriority.Action
	Animation:Play()
	DebounceService:AddDebounce(Humanoid, "UsingSkill", 2.7)

	task.wait(0.5)
	FlashStrike.Attack(Humanoid, Data)
end


function FlashStrike.Attack(Humanoid: Humanoid, Data)
	local state = SkillService:GetSkillState(Humanoid, "FlashStrike")
	local Damage = Data.Damage or 4

	if state == nil then
		return
	end

	local Character = Humanoid.Parent
	local AttackRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Attack")
	RenderService:RenderForPlayers(AttackRenderData)
	local RootPart: BasePart = Humanoid.RootPart

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = { workspace.Enemies, workspace.Characters, workspace.Test }
	Params.FilterType = Enum.RaycastFilterType.Exclude

	local Distance = 34
	local raycast = workspace:Spherecast(RootPart.CFrame.Position, 3, (RootPart.CFrame.LookVector * Distance), Params)
	local DefaltDistance = 34
	if raycast then
		Distance = raycast.Distance
	end

	RootPart.AssemblyLinearVelocity = Vector3.zero
	RootPart.AssemblyAngularVelocity = Vector3.zero
	RootPart.AssemblyLinearVelocity = (
		RootPart.CFrame.LookVector
		* (500 / (DefaltDistance / Distance))
		* WeaponService:GetModelMass(Humanoid.Parent)
	)

	local TInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, false, 0)
	TweenService:Create(Humanoid.RootPart, TInfo, {
		AssemblyLinearVelocity = Vector3.new(0, 0, 0),
	}):Play()

	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Attachment0 = RootPart.RootAttachment
	AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	AlignOrientation.MaxTorque = math.huge
	AlignOrientation.RigidityEnabled = true
	AlignOrientation.CFrame = CFrame.Angles(Humanoid.RootPart.CFrame:ToEulerAnglesXYZ())

	local StartCFrame = Humanoid.RootPart.CFrame
	AlignOrientation.Parent = Humanoid.RootPart
	Debris:AddItem(AlignOrientation, 1.4)

	local HitboxSize = Vector3.new(6, 6, Distance)
	local HitboxCFrame = StartCFrame * CFrame.new(0, 0, -Distance / 2)

	local Enemies = {}
	DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
	HitboxService:CreateFixedHitbox(HitboxCFrame, HitboxSize, 1, function(Enemy)
		if Enemy == Humanoid.Parent then
			return
		end
		if not Enemy:FindFirstChild("Humanoid") then
			return
		end

		local EnemyHumanoid = Enemy:FindFirstChild("Humanoid")

		WeaponService:TriggerHittedEvent(Enemy, Humanoid)

		task.spawn(function()
			local EmitDelayed = false
			if DamageService:GetHitContext(Enemy.Humanoid) == "Hit" then
				DebounceService:AddDebounce(EnemyHumanoid, "Unparryable", 2.3, true)
				WeaponService:Stun(Enemy, Enemy:GetPivot().Position, 2.3)
				table.insert(Enemies, Enemy)
				EmitDelayed = true
			else
				WeaponService:Stun(Enemy, Enemy:GetPivot().Position, 1.5)
			end
				FlashStrike.Hit(Enemy.Humanoid, EmitDelayed, Humanoid)
					
			for _ = 1, 10, 1 do
				DamageService:TryHit(Humanoid, Enemy.Humanoid, math.ceil(Damage * .4), "Sword")
				task.wait(0.1)
			end
		end)
	end)

	task.wait(0.35)
	if #Enemies == 0 then
		AlignOrientation:Destroy()

		Humanoid.RootPart.AssemblyLinearVelocity = Vector3.zero
		DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
		FlashStrike.Cancel(Humanoid)
		SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
		return
	else
		WeaponService:Stun(Character, Character:GetPivot().Position, 1.85)
	end

	task.wait(1.85)
	for _, Enemy in Enemies do
		DamageService:TryHit(Humanoid, Enemy.Humanoid, Damage * 2, "Sword")
	end

	DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
	SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
end

function FlashStrike.Hit(HumanoidHitted: Humanoid, EmitDelayed: boolean?, HumanoidWhoHitted: Humanoid)
	local HitRenderData = RenderService:CreateRenderData(HumanoidHitted, "FlashStrike", "Hit", {EmitDelayed = EmitDelayed or false, HumanoidWhoHitted = HumanoidWhoHitted})
	RenderService:RenderForPlayers(HitRenderData)
end

function FlashStrike.Cancel(Humanoid)
	DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
	AnimationService:StopAnimationMatch(Humanoid, "FlashStrikeAttack", 0.45)
	local CancelRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Cancel")
	RenderService:RenderForPlayers(CancelRenderData)
end

function FlashStrike.Caller(Humanoid: Humanoid, Data: { any }, NeedWeapon)
	if Validate:CanUseSkill(Humanoid, NeedWeapon) and not DebounceService:HaveDebounce(Humanoid, "FlashStrike") then
		FlashStrike.Charge(Humanoid, Data)
	end
end

function FlashStrike.Start()
	AnimationService = Knit.GetService("AnimationService")
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return FlashStrike
