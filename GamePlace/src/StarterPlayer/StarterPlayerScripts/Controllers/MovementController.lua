local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local LeftLeg = Character:WaitForChild("Left Leg")
local RightLeg = Character:WaitForChild("Right Leg")

local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Events = ReplicatedStorage:WaitForChild("Events")
local CameraEvent = Events:WaitForChild("CAMERA")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local ProgressionService

local MovementModule = Knit.CreateController({
	Name = "MovementController",

	TweenInfo = TweenInfo.new(0.5),
	MovementKeys = { Enum.KeyCode.LeftShift },
	ContextName = "ChangeCharacterState",
	CharacterProperties = {
		CharacterState = "WALK",
		Movement = {
			["WALK"] = {
				WalkSpeed = StarterPlayer.CharacterWalkSpeed,
				FOV = 70,
				JumpPower = StarterPlayer.CharacterJumpPower,
			},
			["RUN"] = {
				WalkSpeed = 23,
				FOV = 80,
				JumpPower = StarterPlayer.CharacterJumpPower,
			},
		},
	},
})

function UpdateRunWalkSpeed()
	local calculate = ProgressionService:CalculateSpeed(Player)
	MovementModule.CharacterProperties.Movement.RUN.WalkSpeed += calculate()
end

function MovementModule:ChangeCharacterState(state: CharacterState)
	if self.CharacterProperties.CharacterState == state then
		return
	end
	self.CharacterProperties.CharacterState = state

	local Movement = self.CharacterProperties.Movement[state]

	TweenService:Create(Humanoid, self.TweenInfo, {
		WalkSpeed = Movement.WalkSpeed,
		JumpPower = Movement.JumpPower,
	}):Play()

	CameraEvent:Fire("FOV", Movement.FOV)
end

function MovementModule:CreateContextBinder(): string
	ContextActionService:BindAction(self.ContextName, function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin and self.CharacterProperties.CharacterState == "WALK" then
			if (RootPart:GetVelocityAtPosition(RootPart.CFrame.Position)).Magnitude < 1 then
				return
			end
			self:ChangeCharacterState("RUN")
		elseif state == Enum.UserInputState.Begin and self.CharacterProperties.CharacterState == "RUN" then
			self:ChangeCharacterState("WALK")
		end
	end, false, table.unpack(self.MovementKeys))
	return self.ContextName
end

export type CharacterState = "RUN" | "WALK"

function MovementModule:CreateBinds()
	local EF = ReplicatedStorage:WaitForChild("Models"):WaitForChild("ef")
	local ef1 = EF:Clone()
	local ef2 = EF:Clone()
	ef1.Parent = LeftLeg
	ef2.Parent = RightLeg

	ef1.Enabled = false
	ef2.Enabled = false

	Humanoid.Jumping:Connect(function(active)
		if active then
			ef1.Enabled = false
			ef2.Enabled = false
		end
	end)

	Humanoid.Running:Connect(function(speed)
		if speed < 0.1 then
			MovementModule:ChangeCharacterState("WALK")
		end
		if speed > 16 then
			ef1.Enabled = true
			ef2.Enabled = true
		else
			ef1.Enabled = false
			ef2.Enabled = false
		end
	end)
end

function MovementModule:KnitStart()
	ProgressionService = Knit.GetService("ProgressionService")

	Player.CharacterAdded:Connect(function(character)
		Character = character
		Humanoid = character:WaitForChild("Humanoid")
		RootPart = character:WaitForChild("HumanoidRootPart")
		LeftLeg = character:WaitForChild("Left Leg")
		RightLeg = character:WaitForChild("Right Leg")
	end)

	MovementModule:CreateBinds()
	MovementModule:CreateContextBinder()
end

return MovementModule
