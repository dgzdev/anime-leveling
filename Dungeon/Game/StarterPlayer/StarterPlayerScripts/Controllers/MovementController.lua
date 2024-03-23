local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local CameraEvent = Events:WaitForChild("CAMERA")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local ProgressionService
local StatusController

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
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

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
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local RootPart = Character:WaitForChild("HumanoidRootPart")

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
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local LeftLeg = Character:WaitForChild("Left Leg")
	local RightLeg = Character:WaitForChild("Right Leg")
	local Humanoid = Character:WaitForChild("Humanoid")

	local function CharacterAdded()
		Character = Player.Character or Player.CharacterAdded:Wait()
		LeftLeg = Character:WaitForChild("Left Leg")
		RightLeg = Character:WaitForChild("Right Leg")
		Humanoid = Character:WaitForChild("Humanoid")

		local EF = ReplicatedStorage:WaitForChild("Models"):WaitForChild("ef")
		local ef1 = EF:Clone()
		local ef2 = EF:Clone()
		ef1.Parent = LeftLeg
		ef2.Parent = RightLeg

		ef1.Enabled = false
		ef2.Enabled = false

		Humanoid.Running:Connect(function(speed)
			local Stamina = StatusController:GetStamina()
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

		Humanoid.Jumping:Connect(function(active)
			if active then
				ef1.Enabled = false
				ef2.Enabled = false
			end
		end)
	end

	CharacterAdded()
	Player.CharacterAdded:Connect(CharacterAdded)

	task.spawn(function()
		while true do
			local HRP = Character.PrimaryPart :: BasePart
			local Velocity = HRP:GetVelocityAtPosition(HRP.Position)
			local Stamina = StatusController:GetStamina()

			if Humanoid.Health <= 0 then
				StatusController:ReloadStamina()
			end
			if Velocity.Magnitude > 20 then
				local HumanoidStateType = Humanoid:GetState()
				if HumanoidStateType == Enum.HumanoidStateType.Running then
					if Stamina - 1 < 0 then
						MovementModule:ChangeCharacterState("WALK")
					else
						StatusController:WasteStamina(0.1)
					end
				end
			end
			task.wait(1 / 60)
		end
	end)
end

function MovementModule:KnitInit()
	ProgressionService = Knit.GetService("ProgressionService")
	StatusController = Knit.GetController("StatusController")
end

function MovementModule:KnitStart()
	coroutine.wrap(function()
		MovementModule:CreateBinds()
		MovementModule:CreateContextBinder()
	end)()
end

return MovementModule
