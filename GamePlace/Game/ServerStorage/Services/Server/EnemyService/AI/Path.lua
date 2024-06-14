local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Gamedata = require(game.ServerStorage.GameData)
local Finder = require(script.Parent.Finder)

local Path = {}
Path.Combos = {}
Path.InPath = false
Path.AttackDebounce = false
Path.AlignOriDb = false
Path.MoveDebounce = false
Path.LastContactTick = tick()
Path.Combos.CurrentMelee = 1
Path.CanLeaveCombat = true
Path.HitCount = 0
Path.PlayComboAnim = true
Path.LoadedAnims = false
Path.LastHitTick = nil
Path.Stamina = 100
Path.Data = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local HitboxService
local AnimationService
local WeaponService
local SkillService
local DebugService
local DebounceService
local RagdollService
local AriseService

local AnimationsFolder = ReplicatedStorage:WaitForChild("Animations")

Path.AnimationsTable = nil

local AUTO_PARRY = false
---
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

function Path.ChangeTarget(from, newTarget: Humanoid)
	if not From then
		return
	end
	Path.LeaveFollowing()
	Path.StartFollowing(From, newTarget.RootPart)
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
		AlignOrientation.LookAtPosition = target.Position
	end

	Align = AlignOrientation
	Target = target
	table.insert(
		TargetConnections,
		Target.Parent.Humanoid:GetAttributeChangedSignal("HitboxStart"):Connect(function()
			local state = Target.Parent.Humanoid:GetAttribute("HitboxStart")
			if not state then
				return
			end
			local Data = {
				ParryChance = Path.Data.ParryChance,
				BlockChance = Path.Data.BlockChance,
				AUTO_PARRY = AUTO_PARRY,
			}

			WeaponService:TypeBlockChecker(From, Data)
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

		Path.InPath = true

		task.spawn(function()
			if not From then
				return
			end

			--print(From, Target)
			if
				math.abs(From.RootPart.Position.Y - Target.Position.Y) > 1
				and not Path.AlignOriDb
				and not From.RootPart.Anchored
			then
				From.RootPart:FindFirstChild("LookPlayer").Enabled = false
			else
				From.RootPart:FindFirstChild("LookPlayer").Enabled = true
				Align.LookAtPosition = Target.Position
			end

			if
				Target and (From.RootPart.Position - Target.Position).Magnitude > 120
				or Target.Parent.Humanoid.Health <= 0
			then
				print((From.RootPart.Position - Target.Position).Magnitude)
				Path.LeaveFollowing()
				Path.InPath = false
				return
			end

			task.spawn(function()
				if Target.Parent.Humanoid.Health > 0 and (From.RootPart.Position - Target.Position).Magnitude < 6 then
					if Target.Parent.Humanoid:GetAttribute("LastAttackTick") then
						if math.abs(Target.Parent.Humanoid:GetAttribute("LastAttackTick") - tick()) < 2 then
							WeaponService:TypeBlockChecker(From, {
								ParryChance = Path.Data.ParryChance,
								BlockChance = Path.Data.BlockChance,
								AUTO_PARRY = AUTO_PARRY,
							})
						end
					end

					local randomNumber = math.random(0, 100) / 100
					local flashStrikeChance = 10 / 100

					local isFlashStrike = randomNumber <= flashStrikeChance

					if not isFlashStrike then
						WeaponService:WeaponInput(From.Parent, "Attack")
					else
						Path.AlignOriDb = true
						SkillService:UseSkill(From, "FlashStrike", { Damage = Path.Data.Damage })
						task.delay(5, function()
							Path.AlignOriDb = false
						end)
					end
				end
			end)

			local p = PathfindingService:CreatePath()
			---print(Finder.IsOnDot(Target.Parent.Humanoid, From))
			local Dot = Finder.IsOnDot(Target.Parent.Humanoid, From)
			if Dot and Target:GetVelocityAtPosition(Target.Position).Magnitude > 3 then
				local LeftOrRight

				if
					(From.RootPart.Position - Target.Parent:FindFirstChild("Left Arm").Position).Magnitude
					< (From.RootPart.Position - Target.Parent:FindFirstChild("Right Arm").Position).Magnitude
				then
					LeftOrRight = -1
				else
					LeftOrRight = 1
				end

				--print(Finder.IsOnDot(Target.Parent.Humanoid, From))
				--CFrame.new(12, 0, -5)
				p:ComputeAsync(From.RootPart.Position, (Target.CFrame * CFrame.new(12 * LeftOrRight, 0, -5)).Position)
				--DebugService:CreatePartAtPos((Target.CFrame * CFrame.new(8*RightorLeft,0,-15)).Position)
			else
				p:ComputeAsync(From.RootPart.Position, Target.Position)
			end

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
	if not script:FindFirstAncestorWhichIsA("Actor") then return end
	
	HitboxService = Knit.GetService("HitboxService")
	AnimationService = Knit.GetService("AnimationService")
	SkillService = Knit.GetService("SkillService")
	WeaponService = Knit.GetService("WeaponService")
	DebugService = Knit.GetService("DebugService")
	DebounceService = Knit.GetService("DebounceService")
	RagdollService = Knit.GetService("RagdollService")
	AriseService = Knit.GetService("AriseService")

	local Animator: Animator = Humanoid:WaitForChild("Animator")
	local HittedEvent = script.Parent:WaitForChild("Hitted") :: BindableEvent
	local Connection: RBXScriptSignal

	if Gamedata.gameEnemies[script.Parent.Parent.Parent.Name] then
		Path.Data = Gamedata.gameEnemies[script.Parent.Parent.Parent.Name]
	end

	if not From then
		From = script.Parent.Parent.Parent:FindFirstChildWhichIsA("Humanoid")
	end

	From.Died:Once(function()
		local Char = From.Parent
		local LastHit = From:GetAttribute("LastHitFrom")
		local Player = Players:FindFirstChild(LastHit)
		RagdollService:Ragdoll(Char)
		AriseService:SetPossessionMode(From, Player)
		print("morreu")
	end)

	Connection = HittedEvent.Event:Connect(function(Newtarget: Humanoid)

		From:SetAttribute("LastHitFrom", Newtarget.Parent.Name)

		if Target and Target.Parent ~= Newtarget then
			Path.ChangeTarget(From, Newtarget)
		else
			Path.StartFollowing(From, Newtarget.RootPart)
			local AlignOrientation = From.RootPart:FindFirstChildWhichIsA("AlignOrientation", true)
			task.synchronize()
			if AlignOrientation then
				AlignOrientation.Enabled = true
				AlignOrientation.LookAtPosition = Newtarget.RootPart.Position
				
			end
			Connection:Disconnect()
			Connection = nil
			task.desynchronize()
		end
	end)

	local AnimationsFolder = game.ReplicatedStorage:WaitForChild("Animations")
	Path.AnimationsTable = {
		["Melee"] = {
			["Hit"] = {
				[1] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["0"]:Clone()),
				[2] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["1"]:Clone()),
				[3] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["2"]:Clone()),
				[4] = Animator:LoadAnimation(AnimationsFolder.Melee.Hit["3"]:Clone()),
			},
			["Ground Slam"] = Animator:LoadAnimation(AnimationsFolder.Melee["Ground Slam"]:Clone()),
			["Block"] = Animator:LoadAnimation(AnimationsFolder.Melee["Block"]:Clone()),
		},
	}
end

return Path
