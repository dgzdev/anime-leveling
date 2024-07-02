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
Path.TargetisAlly = false
Path.StopMove = false
Path.Data = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local LootPoolService
local HitboxService
local AnimationService
local WeaponService
local SkillService
local DebugService
local DebounceService
local RagdollService
local AriseService
local DropService

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

local Skills = {
	"FlashStrike",
	"CinderCutter",
	"MoltenSmash"
}

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

	task.synchronize()
	if AlignOrientation then

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
	task.wait()
	loop(function()
		if not script:FindFirstAncestorWhichIsA("Actor") then
			return
		end

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
				math.abs(From.Parent.PrimaryPart.Position.Y - Target.Position.Y) > 1
				and not Path.AlignOriDb
				and not From.RootPart.Anchored
			then
				From.RootPart:FindFirstChild("LookPlayer").Enabled = false
			else

				if Path.TargetisAlly then
					From.RootPart:FindFirstChild("LookPlayer").Enabled = false
				else
					From.RootPart:FindFirstChild("LookPlayer").Enabled = true
					Align.LookAtPosition = Target.Position
				end
			end

			if
				Target and (From.Parent.PrimaryPart.Position - Target.Position).Magnitude > 120 and not Path.TargetisAlly
				or Target.Parent.Humanoid.Health <= 0
			then
				Path.LeaveFollowing()
				Path.InPath = false
				return
			end

			task.spawn(function()
				if Target.Parent.Humanoid.Health > 0 and (From.Parent.PrimaryPart.Position - Target.Position).Magnitude < 6 and not Path.TargetisAlly then
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
					local isSkillChance = 10 / 100

					local isSkill = randomNumber <= isSkillChance

					if not isSkill and not Path.TargetisAlly and (not Target.Parent.Humanoid:GetAttribute("BeingAttacked") or From:GetAttribute("Attacking")) then
						DebounceService:AddDebounce(Target.Parent.Humanoid, "BeingAttacked", 1, true)
						DebounceService:AddDebounce(From, "Attacking", 1, true)
						WeaponService:WeaponInput(From.Parent, "Attack")
					else
						if not Path.TargetisAlly and (not Target.Parent.Humanoid:GetAttribute("BeingAttacked") or From:GetAttribute("Attacking")) then
							DebounceService:AddDebounce(Target.Parent.Humanoid, "BeingAttacked", 1)
							DebounceService:AddDebounce(From, "Attacking", 1)
							Path.AlignOriDb = true
							local Skill = Skills[math.random(1, #Skills)]
							SkillService:UseSkill(From, Skill, { Damage = Path.Data.Damage })
							task.delay(5, function()
								Path.AlignOriDb = false
							end)
						end
					end
				end
			end)

			local p = PathfindingService:CreatePath()
			---print(Finder.IsOnDot(Target.Parent.Humanoid, From))
			local Dot = Finder.IsOnDot(Target.Parent.Humanoid, From)
			if (Dot and Target:GetVelocityAtPosition(Target.Position).Magnitude > 3 and not Path.TargetisAlly) or (Target.Parent.Humanoid:GetAttribute("BeingAttacked") and Dot)then
				local LeftOrRight

				if
					(From.Parent.PrimaryPart.Position - Target.Parent:FindFirstChild("Left Arm").Position).Magnitude
					< (From.Parent.PrimaryPart.Position - Target.Parent:FindFirstChild("Right Arm").Position).Magnitude
				then
					LeftOrRight = -1
				else
					LeftOrRight = 1
				end

				p:ComputeAsync(From.Parent.PrimaryPart.Position, (Target.CFrame * CFrame.new(12 * LeftOrRight, 0, -5)).Position)
				--DebugService:CreatePartAtPos((Target.CFrame * CFrame.new(8*RightorLeft,0,-15)).Position)
			elseif not Path.TargetisAlly then
				p:ComputeAsync(From.Parent.PrimaryPart.Position, Target.Position)
			else
				if (From.Parent.PrimaryPart.Position - Target.Position).Magnitude > 15 then
					DebugService:CreatePartAtPos(From.Parent.PrimaryPart.Position)
					p:ComputeAsync(From.RootPart.Position, (Target.CFrame * CFrame.new(6, 0, 7)).Position)
				else
					Path.StopMove = true
				end
			end

			--if Path.TargetisAlly then
			--	print((From.RootPart.Position - Target.Position).Magnitude)
			--end

			if p.Status == Enum.PathStatus.Success then
				local waypoints = p:GetWaypoints()
				for i, v in pairs(waypoints) do
					if not From.Parent then return end
					if not From.Parent.PrimaryPart or not Target then return end
					if (Path.StopMove or (From.Parent.PrimaryPart.Position - Target.Position).Magnitude < 15) and Path.TargetisAlly then
						Path.StopMove = false
						break
					end
					From:MoveTo(v.Position)
				end
			end

		end)

		task.desynchronize() --> roda em paralelo
	end)
end

function Path.Start(Humanoid: Humanoid)

	if not script:FindFirstAncestorWhichIsA("Actor") then return end

	LootPoolService = Knit.GetService("LootPoolService")
	HitboxService = Knit.GetService("HitboxService")
	AnimationService = Knit.GetService("AnimationService")
	SkillService = Knit.GetService("SkillService")
	WeaponService = Knit.GetService("WeaponService")
	DebugService = Knit.GetService("DebugService")
	DebounceService = Knit.GetService("DebounceService")
	RagdollService = Knit.GetService("RagdollService")
	AriseService = Knit.GetService("AriseService")
	DropService = Knit.GetService("DropService")



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
		
		local Info = DropService:RandomDrop(1, Path.Data.PoolDrop)
		print(Info)
		DropService:DropWeapon(From,Info.Table,Info.HDrop)
		RagdollService:Ragdoll(Char)
		AriseService:SetPossessionMode(From, Player)
	end)

	Connection = HittedEvent.Event:Connect(function(Newtarget: Humanoid)

		From:SetAttribute("LastHitFrom", Newtarget.Parent.Name)
		DebounceService:AddDebounce(Newtarget, "BeingAttacked", 1)
		DebounceService:AddDebounce(From, "Attacking", 1)
		if Target and Target.Parent ~= Newtarget then
			Path.TargetisAlly = false
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
