local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Path = {}
Path.Combos = {}
Path.InPath = false
Path.AttackDebounce = false
Path.Combos.CurrentMelee = 1
Path.HitCount = 0
Path.PlayComboAnim = true
Path.LoadedAnims = false
Path.LastHitTick = nil
Path.Stamina = 100

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local HitboxService
local AnimationService
local WeaponService
local SkillService

local AnimationsFolder = ReplicatedStorage:WaitForChild("Animations")

Path.AnimationsTable = nil

local Op: OverlapParams = nil
local Target: BasePart = nil
local TargetConnections = {}
local From: Humanoid = nil
local Task: thread = nil
local Align: AlignOrientation = nil
local Randomizer = Random.new()

local loop = function(thread: () -> any, ...)
	return task.spawn(function(...)
		while true do
			local stop = thread(...)
			if stop then
				break
			end

			task.wait()
		end
	end)
end

function Path.LeaveFollowing()
	task.synchronize()
	for k, v in TargetConnections do
		v:Disconnect()
		TargetConnections[k] = nil
	end
	Target = nil
	Op = nil
	if not From then
		return
	end
	local AlignOrientation = From.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		AlignOrientation.Enabled = false
	end
	task.desynchronize()
end

function Path.StartFollowing(from: Humanoid, target: BasePart)
	local AlignOrientation = from.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
	if AlignOrientation then
		task.synchronize()
		AlignOrientation.Enabled = true
		AlignOrientation.CFrame = CFrame.lookAt(from.RootPart.Position, target.Position)
	end

	Align = AlignOrientation
	Op = OverlapParams.new()
	Target = target
	table.insert(
		TargetConnections,
		Target.Parent.Humanoid:GetAttributeChangedSignal("HitboxStart"):Connect(function()
			local state = Target.Parent.Humanoid:GetAttribute("HitboxStart")
			if not state then
				return
			end

			local parryChance = 30 / 100
			local blockChance = 45 / 100
			local randomNumber = math.random(0, 100) / 100

			local isParry = randomNumber <= parryChance
			local isBlock = (randomNumber <= blockChance) and not isParry

			if isParry then
				From:SetAttribute("BlockDebounce", false)
				From:SetAttribute("Blocked", false)
				From:SetAttribute("BlockEndLag", false)
				From:SetAttribute("Block", false)
				WeaponService:Block(From.Parent, true)
			elseif isBlock then
				WeaponService:Block(From.Parent, true, true)
			end

			task.delay(0.25, function()
				WeaponService:Block(From.Parent, false)
			end)
		end)
	)
	From = from
	task.desynchronize()
end

do
	loop(function()
		if not Target then
			return
		end
		if not Target.Parent then
			return
		end
		if not Target.Parent.Humanoid then
			return
		end

		task.synchronize() --> roda em serial

		Align.LookAtPosition = Target.Position
		Path.InPath = true

		task.spawn(function()
			if not From then
				return
			end

			if
				Target and (From.RootPart.Position - Target.Position).Magnitude > 50
				or Target.Parent.Humanoid.Health <= 0
			then
				Path.LeaveFollowing()
				Path.InPath = false
				return
			end

			if Target.Parent.Humanoid.Health > 0 and (From.RootPart.Position - Target.Position).Magnitude < 4 then
				local randomNumber = math.random(0, 100) / 100
				local flashStrikeChance = 1 / 100

				local isFlashStrike = randomNumber <= flashStrikeChance

				if not isFlashStrike then
					WeaponService:WeaponInput(From.Parent, "Attack")
				else
					SkillService:UseSkill(From, "FlashStrike")
				end
			end

			local p = PathfindingService:CreatePath()
			p:ComputeAsync(From.RootPart.Position, Target.Position)
			local waypoints = p:GetWaypoints()
			table.remove(waypoints, #waypoints)
			table.remove(waypoints, #waypoints - 1)
			table.remove(waypoints, #waypoints - 2)
			table.remove(waypoints, #waypoints - 3)

			for i, v in pairs(waypoints) do
				From:MoveTo(v.Position)
			end
		end)

		task.desynchronize() --> roda em paralelo
	end)
end

function Path.Start(Humanoid: Humanoid)
	HitboxService = Knit.GetService("HitboxService")
	AnimationService = Knit.GetService("AnimationService")
	SkillService = Knit.GetService("SkillService")
	WeaponService = Knit.GetService("WeaponService")
	local Animator: Animator = Humanoid:WaitForChild("Animator")

	local AnimationsFolder = game.ReplicatedStorage:WaitForChild("Animations")
	Path.AnimationsTable = {
		["Melee"] = {
			["Hit"] = {
				[1] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["1"]:Clone()),
				[2] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["2"]:Clone()),
				[3] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["3"]:Clone()),
				[4] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["4"]:Clone()),
			},
			["Ground Slam"] = Animator:LoadAnimation(AnimationsFolder.Melee["Ground Slam"]:Clone()),
			["Block"] = Animator:LoadAnimation(AnimationsFolder.Melee["Block"]:Clone()),
		},
	}
end

return Path
