local Slide = {}

local RunService = game:GetService("RunService")

local SLIDE_DELAY = 3
local MOMENTUM_START_MULTIPLIER = 2.75
local MOMENTUM_START_MAX = 80
local MOMENTUM_VERTICAL_IMPULSE = 1.35
local MOMENTUM_HORIZONTAL_IMPULSE = 2
local MOMENTUM_DRAG = 1.5
local MOMENTUM_DRAG_MULTIPLIER = 0.03

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")

local Validate = require(game.ReplicatedStorage.Validate)

local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://16728371797"

local SlideAnimation: AnimationTrack = Animator:LoadAnimation(anim)
local momentum

function Slide.GetUp(jumped)
	RunService:UnbindFromRenderStep("BindSlide")
	local SlideBodyVelocity = RootPart:FindFirstChild("SlideBodyVelocity") :: BodyVelocity
	if SlideBodyVelocity then
		SlideAnimation:Stop(0.3)
		SlideBodyVelocity:Destroy()

		if jumped then
			local _maxMomentum = math.clamp(momentum, 0, 30)
			RootPart:ApplyImpulse(
				(RootPart.CFrame.LookVector * (_maxMomentum * MOMENTUM_HORIZONTAL_IMPULSE))
					+ Vector3.new(0, MOMENTUM_VERTICAL_IMPULSE * _maxMomentum, 0)
			)
		end
	end

	local SlideBodyGyro = RootPart:FindFirstChild("SlideBodyGyro")

	if SlideBodyGyro then
		SlideBodyGyro:Destroy()
	end
	Humanoid:SetAttribute("Slide", false)
end

function Slide.Slide()
	if not Validate:CanSlide(Humanoid) then
		return
	end

	if RootPart:GetVelocityAtPosition(RootPart.Position).Magnitude <= 8 then
		return
	end

	momentum = math.clamp(RootPart.AssemblyLinearVelocity.Magnitude * MOMENTUM_START_MULTIPLIER, 0, MOMENTUM_START_MAX)

	local SlideBodyVelocity = Instance.new("BodyVelocity")
	SlideBodyVelocity.MaxForce = Vector3.new(1, 0, 1) * 100000
	SlideBodyVelocity.Name = "SlideBodyVelocity"

	local SlideBodyGyro = Instance.new("BodyGyro")
	SlideBodyGyro.MaxTorque = Vector3.new(1, 0, 1) * 50000
	SlideBodyGyro.Name = "SlideBodyGyro"

	Humanoid:SetAttribute("LastSlideTick", tick() + SLIDE_DELAY)

	local RayParams = RaycastParams.new()
	RayParams.FilterDescendantsInstances = { Character }
	RayParams.FilterType = Enum.RaycastFilterType.Exclude

	if RootPart.AssemblyLinearVelocity.Magnitude <= 1 then
		return
	end

	Humanoid.Jumping:Once(function()
		Slide.GetUp(true)
	end)

	RunService:BindToRenderStep("BindSlide", Enum.RenderPriority.Character.Value, function(dt)
		local Raycast = game.Workspace:Raycast(RootPart.CFrame.Position, Vector3.new(0, -5, 0), RayParams)

		if Raycast then
			local Normal = Raycast.Normal
			local PartRay = Raycast.Instance
			local Incline = PartRay.CFrame.RightVector:Cross(Normal)

			if Incline.Magnitude == 0 then
				Incline = Vector3.new(1, 0, 0)
			end

			local angle = math.acos(Vector3.new(0, 1, 0):Dot(Incline))
			local spd = math.abs(Normal.X) + math.abs(Normal.Z) * dt

			local anglediff = (RootPart.CFrame.LookVector - PartRay.CFrame.LookVector).Magnitude
			if spd > 0.25 and anglediff <= 1.2 then
				if not Humanoid:GetAttribute("Slide") then
					Humanoid:SetAttribute("Slide", true)

					if not SlideAnimation.IsPlaying then
						SlideAnimation:Play()
					end
				end

				momentum += angle / MOMENTUM_DRAG
				momentum = math.clamp(momentum, 0, 200)
				SlideBodyVelocity.Parent = RootPart
				SlideBodyVelocity.Velocity = (RootPart.CFrame.LookVector * momentum)
			else
				if RootPart.AssemblyLinearVelocity.Magnitude <= 1 and not Humanoid:GetAttribute("Slide") then
					return
				else
					if not Humanoid:GetAttribute("Slide") then
						Humanoid:SetAttribute("Slide", true)
					end

					if not SlideAnimation.IsPlaying then
						SlideAnimation:Play(0.15)
						SlideAnimation:GetMarkerReachedSignal("end"):Once(function()
							SlideAnimation:AdjustSpeed(0)
						end)
						SlideAnimation.Looped = true
					end

					if SlideBodyVelocity then
						SlideBodyVelocity.Velocity = (RootPart.CFrame.LookVector * momentum)
						SlideBodyVelocity.Parent = RootPart
					end

					SlideBodyGyro.CFrame = RootPart.CFrame
					SlideBodyGyro.Parent = RootPart
					momentum -= momentum * MOMENTUM_DRAG_MULTIPLIER

					if momentum <= 5 or RootPart.AssemblyLinearVelocity.Magnitude <= 10 then
						Slide.GetUp()
					end
				end
			end
		else
			momentum -= momentum * MOMENTUM_DRAG_MULTIPLIER
			if momentum <= 5 or RootPart.AssemblyLinearVelocity.Magnitude <= 12 then
				Slide.GetUp()
			end
		end
	end)
end
function Slide:Init(modules)
	local uis = game:GetService("UserInputService")

	local SlideButtons = { Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonB }
	local GetUpButtons = { Enum.KeyCode.Space, Enum.KeyCode.ButtonA }

	uis.InputBegan:Connect(function(key, gp)
		if gp then
			return
		end
		if table.find(GetUpButtons, key.KeyCode) then
			if Humanoid:GetAttribute("Slide") then
				Slide.GetUp(true)
			end
		elseif table.find(SlideButtons, key.KeyCode) then
			Slide.Slide()
		end
	end)

	Humanoid:GetAttributeChangedSignal("SlideGetUp"):Connect(function()
		if Humanoid:GetAttribute("SlideGetUp") then
			Slide.GetUp()
		end
	end)

	local ContextActionService = game:GetService("ContextActionService")
	ContextActionService:BindAction("Slide", function(action: string, state: Enum.UserInputState, object)
		if state ~= Enum.UserInputState.Begin then
			return
		end

		Slide.Slide()
	end, true, Enum.KeyCode.C)
end

return Slide
