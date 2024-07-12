local ContextActionService = game:GetService("ContextActionService")
local DashScript = {}

local Knit = require(game.ReplicatedStorage.Packages.Knit)

Knit.OnStart():await()

local StatusController = Knit.GetController("StatusController")
local CameraController = Knit.GetController("CameraController")
local UIDebounceController = Knit.GetController("UIDebounceController")

local Debris = game:GetService("Debris")
local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local SFX = require(ReplicatedStorage.Modules.SFX)
local Validate = require(ReplicatedStorage.Validate)

local Slide

local function IsMouseLocked()
	return CameraController:IsLocked()
end

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless == true then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
end

local VFX = require(game.ReplicatedStorage.Modules.VFX)

local function CreateAnimationWithID(id: string): AnimationTrack
	local a = Instance.new("Animation")
	a.AnimationId = `rbxassetid://{id}`

	local track: AnimationTrack = Animator:LoadAnimation(a)

	return track
end

local DashAnimations = {
	["F"] = {
		speed = 1,
		anim = CreateAnimationWithID("16526303689"),
	},
	["B"] = {
		speed = 1,
		anim = CreateAnimationWithID("16526306820"),
	},
	["L"] = {
		speed = 1.5,
		anim = CreateAnimationWithID("16526295276"),
	},
	["R"] = {
		speed = 1.5,
		anim = CreateAnimationWithID("16526290641"),
	},
}

local walkKeyBinds = {
	Forward = { Key = Enum.KeyCode.W, Direction = Enum.NormalId.Front },
	Backward = { Key = Enum.KeyCode.S, Direction = Enum.NormalId.Back },
	Left = { Key = Enum.KeyCode.A, Direction = Enum.NormalId.Left },
	Right = { Key = Enum.KeyCode.D, Direction = Enum.NormalId.Right },
}

local function getWalkDirectionCameraSpace()
	local walkDir = Vector3.new()

	for keyBindName, keyBind in walkKeyBinds do
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
	if DashDirection.Magnitude < 0.1 then
		DashDirection = HumanoidRootPart.CFrame.LookVector.Unit
	end

	if tick() < Cooldown then
		return
	end

	if not Validate:CanRoll(Humanoid) then
		return
	end

	if Humanoid:GetAttribute("Slide") then
		Slide.GetUp()
	end

	Cooldown = tick() + 1.5

	UIDebounceController:AddDebounce("Dash", 1.5)

	local Animation

	if IsMouseLocked() then
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
		Animation = id.anim
	else
		Animation = DashAnimations.F.anim
	end

	Animation:Play()

	SFX:Apply(Character, "Dash")

	local mass = GetModelMass(Character)
	local DashVelocity = DashDirection * 100 * mass
	HumanoidRootPart.AssemblyLinearVelocity = DashVelocity

	Animation.Ended:Wait()
end

local DashButtons = { Enum.KeyCode.Q, Enum.KeyCode.ButtonL1 }

function DashScript:Init(Modules)
	Slide = Modules.Slide

	ContextActionService:BindAction("Dash", function(action: string, state: Enum.UserInputState, object)
		if state ~= Enum.UserInputState.Begin then
			return
		end

		self:Dash()
	end, true, table.unpack(DashButtons))
end

return DashScript
