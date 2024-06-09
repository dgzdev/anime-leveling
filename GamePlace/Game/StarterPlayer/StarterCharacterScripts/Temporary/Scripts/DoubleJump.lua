local DoubleJump = {}
local Knit = require(game.ReplicatedStorage.Packages.Knit)

Knit.OnStart():await()

local DebugService = Knit.GetService("DebugService")
local RunService = game:GetService("RunService")
local GrabService = Knit.GetService("GrabService")

local SFX = require(game.ReplicatedStorage.Modules.SFX)
local Validate = require(game.ReplicatedStorage.Validate)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
end

local function stopPlayingTracks(animator: Animator)
	local anims = animator:GetPlayingAnimationTracks()

	for _index, anim in anims do
		anim:Stop(0)
	end
end
local function playAnimation(animation: Animation, animator: Animator)
	local track = animator:LoadAnimation(animation)
	track:Play(0)
	return track
end

function DoubleJump:Init()
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()

	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	local animator: Animator = humanoid:WaitForChild("Animator")
	local doubleJump: Animation = game.ReplicatedStorage.Animations.DoubleJump
	local doubleJumpTrack: AnimationTrack = animator:LoadAnimation(doubleJump)

	local jumpUsage = 1

	local uis = game:GetService("UserInputService")

	uis.InputBegan:Connect(function(key, gp)
		if (key.KeyCode == Enum.KeyCode.Space) or (key.KeyCode == Enum.KeyCode.ButtonA) and not gp then
			if humanoidRootPart and humanoid then
				if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					if jumpUsage >= 1 and Validate:CanDoubleJump(humanoid) then
						jumpUsage -= 1

						local LookV = humanoid.MoveDirection * 75 * GetModelMass(char)
						humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
						humanoidRootPart.AssemblyLinearVelocity = LookV + Vector3.new(0, 60, 0)
						local timerStart = tick()

						doubleJumpTrack:Play()

						task.spawn(function()
							repeat
								RunService.RenderStepped:Wait()

								DebugService.AttachPart = true

								local params = RaycastParams.new()
								params.FilterType = Enum.RaycastFilterType.Exclude
								params.RespectCanCollide = true
								params.FilterDescendantsInstances = { char, workspace:FindFirstChild("Debug") }

								local rayResult = workspace:Spherecast(
									player.Character.Head.CFrame.Position,
									4,
									Vector3.new(1, 10, 1),
									params
								)

								if rayResult then
									if rayResult.Instance then
										local msize = 0
										local inst = rayResult.Instance
										if inst:IsA("Model") then
											msize = inst:GetExtentsSize().Magnitude
										elseif inst:IsA("BasePart") then
											msize = inst.Size.Magnitude
										end

										if msize > 50 then
											continue
										end

										local rootPartLocation = char:GetPivot().Position
											- humanoid.RootPart.CFrame.Position

										stopPlayingTracks(animator)

										local size = char:GetExtentsSize()

										local y, x, z = char:GetPivot():ToOrientation()
										local position = rayResult.Position - Vector3.new(0, size.Y * 0.4, 0)
										local cframe = CFrame.new(position) * CFrame.fromEulerAnglesYXZ(y, x, z)

										local rootpartP = cframe * CFrame.new(rootPartLocation)
										local rootpartE = humanoid.RootPart.Size

										local part = Instance.new("Part", workspace)

										local ovp = OverlapParams.new()
										ovp.FilterDescendantsInstances = { char, part }
										ovp.FilterType = Enum.RaycastFilterType.Exclude

										part.Anchored = true
										part.CanCollide = false
										part.Transparency = 1
										part.CFrame = rootpartP
										part.Size = rootpartE
										part.Massless = true
										part.Name = "CollideChecker"

										local collideParts = workspace:GetPartsInPart(part, ovp)
										if #collideParts > 0 then
											part:Destroy()
											continue
										end

										--> ===================================================

										part:Destroy()

										local Animation = Instance.new("Animation")
										Animation.AnimationId = "rbxassetid://17734821435"
										local AnimationTrack: AnimationTrack = playAnimation(Animation, animator)
										char.PrimaryPart.Anchored = true
										humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
										humanoid:ChangeState(Enum.HumanoidStateType.StrafingNoPhysics)

										local speedPerSecond = 15
										RunService:BindToRenderStep(
											"Grabbing",
											Enum.RenderPriority.Character.Value,
											function(deltaTime)
												char:PivotTo(char:GetPivot():Lerp(cframe, deltaTime * speedPerSecond))
											end
										)

										task.delay(0.25, function()
											GrabService:Grab(cframe)
										end)

										char.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
										char.PrimaryPart.AssemblyAngularVelocity = Vector3.new()

										local connection
										connection = uis.InputBegan:Connect(function(input, gpe)
											if gpe then
												return
											end

											if input.KeyCode == Enum.KeyCode.Space then
												connection:Disconnect()
												char.PrimaryPart.Anchored = false
												humanoid:SetStateEnabled(
													Enum.HumanoidStateType.StrafingNoPhysics,
													false
												)
												humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
												AnimationTrack:Stop(0)
												RunService:UnbindFromRenderStep("Grabbing")
												GrabService:Ungrab()
											end
										end)

										break
									end
								end
							until tick() - timerStart >= 0.5
						end)

						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						SFX:Apply(char.HumanoidRootPart, "Jump")
						local connection
						connection = humanoid.StateChanged:Connect(function(old, new)
							if new == Enum.HumanoidStateType.Landed then
								jumpUsage = 1
								connection:Disconnect()
							end
						end)
					end
				end
			end
		end
	end)
end

return DoubleJump
