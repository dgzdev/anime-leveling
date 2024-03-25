local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local TILT_SIZE = 150

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root: BasePart
local RootJoint: Motor6D

local Angle1 = 0
local Angle2 = 0
local Direction
local Velocity

local ORIGINAL_C0
local CHARACTER_RIG_TYPE = Humanoid.RigType

if CHARACTER_RIG_TYPE == Enum.HumanoidRigType.R6 then
	Root = Character:WaitForChild("HumanoidRootPart")
	RootJoint = Root:WaitForChild("RootJoint")
else
	Root = Character:WaitForChild("LowerTorso")
	RootJoint = Root:WaitForChild("Root")
end

ORIGINAL_C0 = RootJoint.C0

local function Heartbeat()
	if Humanoid.Health > 0 then
		Velocity = Root:GetVelocityAtPosition(Root.Position) * Vector3.new(1, 0, 1)

		if Velocity.Magnitude > 2 then
			Direction = Velocity.Unit

			Angle1 = Root.CFrame.LookVector:Dot(Direction) / (1000 / TILT_SIZE)
			Angle2 = Root.CFrame.RightVector:Dot(Direction) / (1000 / TILT_SIZE)
		else
			-- Resets the angles because player is moving too slow

			Angle1 = 0
			Angle2 = 0
		end

		local TiltGoal = { C0 = ORIGINAL_C0 * CFrame.Angles(0, -Angle2, 0) }
		local TiltTween = TweenService:Create(RootJoint, TweenInfo.new(0.2), TiltGoal)

		TiltTween:Play()
	end
end

RunService.Heartbeat:Connect(Heartbeat)
