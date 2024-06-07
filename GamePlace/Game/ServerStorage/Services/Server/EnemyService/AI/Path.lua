local Path = {}
Path.Combos = {}
Path.InPath = false
Path.AttackDebounce = false
Path.Combos.CurrentMelee = 1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local AnimationsFolder = ReplicatedStorage:WaitForChild("Animations")
local Target: BasePart = nil
local From: Humanoid = nil
local Task: thread = nil
local Align: AlignOrientation = nil

local defaultDelay = 0

local loop = function(thread: () -> any, ...)
	return task.spawn(function(...)
		while true do
			local stop = thread(...)
			if stop then
				break
			end
			task.wait(defaultDelay)
		end
	end)
end

function Path.LeaveFollowing()
	task.synchronize()
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
	if AlignOrientation then
		task.synchronize()
		AlignOrientation.Enabled = true
	end
	task.desynchronize()
	Align = AlignOrientation

	Target = target
	From = from
end

do
	loop(function()
		if not Target then
			return
		end

		task.synchronize() --> roda em serial

		--> Se setar o CFrame da RootPart, o personagem fica todo travado
		--> AlignOrientation

		Align.LookAtPosition = Target.Position
		Path.InPath = true

		task.spawn(function()
			if (From.RootPart.Position - Target.Position).Magnitude > 50 or Target.Parent.Humanoid.Health <= 0 then
				Path.LeaveFollowing()
				Path.InPath = false
				return
			end

			if Target.Parent.Humanoid.Health > 0 and (From.RootPart.Position - Target.Position).Magnitude < 4 then
				if Path.AttackDebounce then
					return
				end
				From.WalkSpeed = 8
				local HitAnimations = AnimationsFolder.Melee.Hit
				local CurrentHitAnimation = HitAnimations[Path.Combos.CurrentMelee]:Clone() :: Animation
				local AnimationTrack =
					From:FindFirstChildWhichIsA("Animator"):LoadAnimation(CurrentHitAnimation) :: AnimationTrack

				AnimationTrack:Play(0.3)
				Path.AttackDebounce = true
				task.delay(AnimationTrack.Length, function()
					Path.AttackDebounce = false
					CurrentHitAnimation:Destroy()
					if not HitAnimations:FindFirstChild(Path.Combos.CurrentMelee + 1) then
						Path.Combos.CurrentMelee = 1
					else
						Path.Combos.CurrentMelee += 1
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

return Path
