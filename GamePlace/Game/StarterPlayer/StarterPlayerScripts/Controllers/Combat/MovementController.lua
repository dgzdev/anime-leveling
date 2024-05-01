local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

local taps = 0
local lastTap = tick()
local keys = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D }

function MovementModule:CreateContextBinder(): string
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		for _, k in keys do
			if input.KeyCode == k then
				if taps == 0 then
					taps += 1
				else
					if tick() - lastTap < 0.25 then
						taps = math.clamp(taps + 1, 0, 2)
					end

					if taps == 2 then
						MovementModule:ChangeCharacterState("RUN")
					end
				end
				lastTap = tick()
				return
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if tick() - lastTap > 0.25 then
			taps = 0
		end
	end)
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
			if speed < 0.1 then
				local keysDown = 0
				for _, key in ipairs(keys) do
					if UserInputService:IsKeyDown(key) then
						keysDown += 1
					end
				end
				if keysDown == 0 then
					MovementModule:ChangeCharacterState("WALK")
				end
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
