local Debris = game:GetService("Debris")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local HitboxService
local RenderService
local SkillService
local DebounceService
local DamageService
local WeaponService

local Validate = require(game.ReplicatedStorage.Validate)

local FlashStrike = {}

local Cooldown = 5
function FlashStrike.Charge(Humanoid: Humanoid, Data: {any})
	DebounceService:AddDebounce(Humanoid, "FlashStrike", Cooldown, false)
	SkillService:SetSkillState(Humanoid, "FlashStrike", "Charge")

	local ChargeRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Charge")
	RenderService:RenderForPlayers(ChargeRenderData)

	DebounceService:AddDebounce(Humanoid, "UsingSkill", 2.7)

	task.wait(0.5)
	FlashStrike.Attack(Humanoid, Data)
end

function FlashStrike.Attack(Humanoid: Humanoid)
	local AttackRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Attack")
	RenderService:RenderForPlayers(AttackRenderData)
	local RootPart = Humanoid.RootPart

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {Humanoid.Parent, workspace.Test}
	Params.FilterType = Enum.RaycastFilterType.Exclude

	local raycast = workspace:Spherecast(RootPart.CFrame.Position, 3, (RootPart.CFrame.LookVector * 25), Params)

	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Attachment0 = RootPart.RootAttachment
	AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	AlignPosition.MaxVelocity = math.huge
	AlignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	AlignPosition.MaxAxesForce = Vector3.new(1, 0, 1) * math.huge
	AlignPosition.Name = "FlashStrikeAlignPosition"
	AlignPosition.Responsiveness = 35

	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Attachment0 = RootPart.RootAttachment
	AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	AlignOrientation.MaxTorque = math.huge
	AlignOrientation.RigidityEnabled = true
	AlignOrientation.CFrame = CFrame.Angles(Humanoid.RootPart.CFrame:ToEulerAnglesXYZ())

	local Distance = 50
	if raycast then
		Distance = raycast.Distance
		AlignPosition.Position = (RootPart.CFrame * CFrame.new(0, 0, -raycast.Distance)).Position
	else
		AlignPosition.Position = (RootPart.CFrame * CFrame.new(0, 0, -Distance)).Position
	end

	local StartCFrame = Humanoid.RootPart.CFrame
	AlignOrientation.Parent = Humanoid.RootPart
	AlignPosition.Parent = RootPart
	Debris:AddItem(AlignPosition, 3)
	Debris:AddItem(AlignOrientation, 3)

	local HitboxSize = Vector3.new(5, 5, Distance)
	local HitboxCFrame = StartCFrame * CFrame.new(0, 0, -Distance/2)

	local Enemies = {}
	HitboxService:CreateFixedHitbox(HitboxCFrame, HitboxSize, 1, function(Enemy)
		table.insert(Enemies, Enemy)

		task.spawn(function()
			if DamageService:GetHitContext(Enemy.Humanoid) == "Hit" then
				WeaponService:Stun(Enemy, Enemy:GetPivot().Position, 3)
			end
			for _ = 1, 10, 1 do
				DamageService:TryHit(Humanoid, Enemy.Humanoid, 4, "Sword")
				task.wait(0.1)
			end
		end)
	end)

	task.wait(0.35)
	if #Enemies == 0 then
		AlignPosition:Destroy()
		AlignOrientation:Destroy()

		Humanoid.RootPart.AssemblyLinearVelocity = Vector3.zero
		DebounceService:RemoveDebounce(Humanoid, "UsingSkill")
		FlashStrike.Cancel(Humanoid)
		SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
	end

	task.wait(1.85)
	for _, Enemy in Enemies do
		print(Enemy)
		DamageService:Hit(Enemy.Humanoid, Humanoid, 20, "Sword")
	end

	SkillService:SetSkillState(Humanoid, "FlashStrike", nil)
end

function FlashStrike.Cancel(Humanoid)
	local CancelRenderData = RenderService:CreateRenderData(Humanoid, "FlashStrike", "Cancel")
	RenderService:RenderForPlayers(CancelRenderData)
end


function FlashStrike.Caller(Humanoid: Humanoid, Data: {any})
	if Validate:CanAttack(Humanoid) and not DebounceService:HaveDebounce(Humanoid, "FlashStrike") then
		FlashStrike.Charge(Humanoid, Data)
	end
end

function FlashStrike.Start()
	WeaponService = Knit.GetService("WeaponService")
	DebounceService = Knit.GetService("DebounceService")
	SkillService = Knit.GetService("SkillService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	RenderService = Knit.GetService("RenderService")
end

return FlashStrike