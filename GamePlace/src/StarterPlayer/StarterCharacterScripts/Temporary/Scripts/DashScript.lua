local ContextActionService = game:GetService("ContextActionService")
local DashScript = {}

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			mass += part:GetMass()
		end
	end
	return mass
end

local function CheckHigher(Vector: Vector3)
	if math.abs(Vector.X) > math.abs(Vector.Z) then
		return "X"
	else
		return "Z"
	end
end

local VFX = require(game.ReplicatedStorage.Modules.VFX)

local DashAnimations = {
	["F"] = "16526303689",
	["B"] = "16526306820",
	["L"] = "16526295276",
	["R"] = "16526290641",
}

local walkKeyBinds = {
	Forward = { Key = Enum.KeyCode.W, Direction = Enum.NormalId.Front },
	Backward = { Key = Enum.KeyCode.S, Direction = Enum.NormalId.Back },
	Left = { Key = Enum.KeyCode.A, Direction = Enum.NormalId.Left },
	Right = { Key = Enum.KeyCode.D, Direction = Enum.NormalId.Right },
}

local function getWalkDirectionCameraSpace()
	local walkDir = Vector3.new()

	for keyBindName, keyBind in pairs(walkKeyBinds) do
		if UserInputService:IsKeyDown(keyBind.Key) then
			walkDir += Vector3.FromNormalId(keyBind.Direction)
		end
	end

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local Cooldown = 0

function DashScript:Dash()
	local DashDirection = Humanoid.MoveDirection

	if tick() < Cooldown then
		return
	end

	if Humanoid.WalkSpeed == 0 then
		return
	end

	if HumanoidRootPart.Anchored then
		return
	end

	if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		return
	end

	if DashDirection.Magnitude == 0 then
		return
	end

	if Humanoid.Health <= 0 then
		return
	end

	Cooldown = tick() + 1.5
	local Animation = Instance.new("Animation")

	local WalkDirWorld = getWalkDirectionCameraSpace()

	local DashDiretionString = ""
	if WalkDirWorld.X > 0 then
		DashDiretionString = "R"
	elseif WalkDirWorld.X < 0 then
		DashDiretionString = "L"
	elseif WalkDirWorld.Z > 0 then
		DashDiretionString = "B"
	elseif WalkDirWorld.Z < 0 then
		DashDiretionString = "F"
	end

	if not DashDiretionString then
		return
	end

	local id = DashAnimations[DashDiretionString or "F"] or DashAnimations.F
	Animation.AnimationId = `rbxassetid://{id or DashAnimations.F}`
	local AnimationTrack = Animator:LoadAnimation(Animation)

	VFX:ApplyParticle(Character, "Smoke")

	local Stripes = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Stripes"):Clone()

	Stripes.Parent = Workspace.Terrain

	if DashDiretionString == "F" or DashDiretionString == "B" then
		for _, p: ParticleEmitter in ipairs(Stripes:GetChildren()) do
			if p:IsA("ParticleEmitter") then
				p.Orientation = Enum.ParticleOrientation.VelocityParallel
			end
		end
	end

	task.wait()
	AnimationTrack:Play()
	AnimationTrack:AdjustSpeed(1)
	RunService:BindToRenderStep("DashEffects", Enum.RenderPriority.Last.Value, function()
		Stripes.CFrame = HumanoidRootPart.CFrame

		for _, p: ParticleEmitter in ipairs(Stripes:GetChildren()) do
			if p:IsA("ParticleEmitter") then
				p:Emit(1)
			end
		end

		if not AnimationTrack.IsPlaying then
			Stripes:Destroy()
			RunService:UnbindFromRenderStep("DashEffects")
		end
	end)

	local DashVelocity = DashDirection * 40 * GetModelMass(Character)
	HumanoidRootPart.AssemblyLinearVelocity = DashVelocity
end

function DashScript:Init()
	ContextActionService:BindAction("Dash", function(action: string, state: Enum.UserInputState, object)
		if state ~= Enum.UserInputState.Begin then
			return
		end

		self:Dash()
	end, true, Enum.KeyCode.Q)
end

return DashScript
