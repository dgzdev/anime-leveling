local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Path = {}
Path.Combos = {}
Path.InPath = false
Path.AttackDebounce = false
Path.Combos.CurrentMelee = 1
Path.HitCount = 0
Path.PlayComboAnim = true
Path.LastHitTick = nil
Path.Stamina = 100

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local HitboxService
local AnimationService

local AnimationsFolder = ReplicatedStorage:WaitForChild("Animations")
local Op: OverlapParams = nil
local Target: BasePart = nil
local From: Humanoid = nil
local Task: thread = nil
local Align: AlignOrientation = nil

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
	end
	task.desynchronize()
	Align = AlignOrientation

	Op = OverlapParams.new()
	Target = target
	From = from
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

			if
				Path.PlayComboAnim
				and Target.Parent.Humanoid.Health > 0
				and (From.RootPart.Position - Target.Position).Magnitude < 4
			then ------------> Perto o suficiente para executar M1's
				if Path.AttackDebounce then
					return
				end
				Path.AttackDebounce = true
				Op.FilterType = Enum.RaycastFilterType.Exclude
				Op.FilterDescendantsInstances = { From.Parent }
				From.WalkSpeed = 8
				local HitAnimations = AnimationsFolder.Melee.Hit
				local CurrentHitAnimation = HitAnimations[Path.Combos.CurrentMelee]:Clone() :: Animation
				local Animator = From:FindFirstChildWhichIsA("Animator") :: Animator
				local AnimationTrack = Animator:LoadAnimation(CurrentHitAnimation) :: AnimationTrack

				AnimationTrack:Play()
				AnimationTrack:AdjustSpeed(1)

				AnimationTrack:GetMarkerReachedSignal("Hit"):Connect(function()
					HitboxService:CreateFixedHitbox(
						From.RootPart.CFrame * CFrame.new(0, 0, -2),
						Vector3.new(3, 3, 3),
						1,
						function(Hitted)
							if Path.LastHitTick and Path.LastHitTick - tick() <= 1 then
								Path.HitCount += 1
								if Path.HitCount >= #HitAnimations:GetChildren() then
									Path.HitCount = 0
									Path.PlayComboAnim = false
									AnimationService:StopAllAnimations(From, 0.5)

									local UltAnimation = AnimationsFolder.Melee["Ground Slam"]:Clone() :: Animation
									local UltAnimationTrack = Animator:LoadAnimation(UltAnimation) :: AnimationTrack

									UltAnimationTrack:Play()
									task.delay(UltAnimationTrack.Length * 1.5, function()
										Path.AttackDebounce = false
										Path.Combos.CurrentMelee = 1
										Path.PlayComboAnim = true
									end)
								end
							end
							print(Path.HitCount)
							Path.LastHitTick = tick()
						end,
						Op
					)
				end)
				task.delay(AnimationTrack.Length, function()
					if not Path.PlayComboAnim then
						Path.PlayComboAnim = true
						return
					end
					CurrentHitAnimation:Destroy()
					if not HitAnimations:FindFirstChild(Path.Combos.CurrentMelee + 1) then
						Path.Combos.CurrentMelee = 1
						task.delay(2, function()
							Path.AttackDebounce = false
						end)
					else
						Path.Combos.CurrentMelee += 1
						Path.AttackDebounce = false
					end
				end)
			else
				From.WalkSpeed = 16
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

function Path.Start()
	HitboxService = Knit.GetService("HitboxService")
	AnimationService = Knit.GetService("AnimationService")
end

return Path
