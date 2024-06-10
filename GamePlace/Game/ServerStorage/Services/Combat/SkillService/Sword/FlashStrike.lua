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

local Cooldown = 5
function FlashStrike.Charge(Humanoid: Humanoid, Data: { any })
	DebounceService:AddDebounce(Humanoid, "FlashStrike", Cooldown, false)
	SkillService:SetSkillState(Humanoid, "FlashStrike", "Charge")

	local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

	DebounceService:AddDebounce(Humanoid, "UsingSkill", 2.7)

	local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.Skills.FlashStrike.FlashStrikeAttack)
	Animation.Priority = Enum.AnimationPriority.Action
	Animation:Play()

	task.wait(0.5)
	FlashStrike.Attack(Humanoid, Data)
end

function GetModelMass(model: Model): number
	local mass = 1
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless == true then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass
end

function FlashStrike.Attack(Humanoid: Humanoid)
	local state = SkillService:GetSkillState(Humanoid, "FlashStrike") 
	if state == nil or state == "Cancel" then
		return
	end

	local Character = Humanoid.Parent
	local AttackRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Attack")
	RenderService:RenderForPlayers(AttackRenderData)
	local RootPart: BasePart = Humanoid.RootPart

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = { workspace.Enemies, workspace.Characters, workspace.Test }
	Params.FilterType = Enum.RaycastFilterType.Exclude

	local raycast = workspace:Spherecast(RootPart.CFrame.Position, 3, (RootPart.CFrame.LookVector * 25), Params)

	local Distance = 50
	local DefaltDistance = 50
	if raycast then
		Distance = raycast.Distance
	end

	RootPart.AssemblyLinearVelocity = Vector3.zero
	RootPart.AssemblyAngularVelocity = Vector3.zero
	RootPart.AssemblyLinearVelocity = (
		RootPart.CFrame.LookVector
		* (600 / (DefaltDistance / Distance))
		* GetModelMass(Humanoid.Parent)
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

	Debris:AddItem(AlignOrientation, 3)

	local HitboxSize = Vector3.new(5, 5, Distance)
	local HitboxCFrame = StartCFrame * CFrame.new(0, 0, -Distance / 2)

	local Enemies = {}
	HitboxService:CreateFixedHitbox(HitboxCFrame, HitboxSize, 1, function(Enemy)
		if Enemy == Humanoid.Parent then
			return
		end
		task.spawn(function()
			Humanoid:SetAttribute("HitboxStart", true)
			if DamageService:GetHitContext(Enemy.Humanoid) == "Hit" then
				WeaponService:Stun(Enemy, Enemy:GetPivot().Position, 2.2)
				table.insert(Enemies, Enemy)
			else
				WeaponService:Stun(Enemy, Enemy:GetPivot().Position, 1.5)
			end

			for _ = 1, 10, 1 do
				DamageService:TryHit(Humanoid, Enemy.Humanoid, 4, "Sword")
				task.wait(0.1)
			end
		end)
	end)

	task.wait(0.35)
	Humanoid:SetAttribute("HitboxStart", false)
	if #Enemies == 0 then
		AlignOrientation:Destroy()

		Humanoid.RootPart.AssemblyLinearVelocity = Vector3.zero
		DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
		FlashStrike.Cancel(Humanoid)
		SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
	else
		WeaponService:Stun(Character, Character:GetPivot().Position, 1.85)
	end

	task.wait(1.85)
	for _, Enemy in Enemies do
		DamageService:Hit(Enemy.Humanoid, Humanoid, 20, "Sword")
	end

	DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
	SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
end

function FlashStrike.Cancel(Humanoid)
	print("cancelled")
	DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
	AnimationService:StopAnimationMatch(Humanoid, "FlashStrikeAttack", 0.45)
	local CancelRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Cancel")
	RenderService:RenderForPlayers(CancelRenderData)
end

function FlashStrike.Caller(Humanoid: Humanoid, Data: { any })
	if Validate:CanUseSkill(Humanoid) and not DebounceService:HaveDebounce(Humanoid, "FlashStrike") then
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
