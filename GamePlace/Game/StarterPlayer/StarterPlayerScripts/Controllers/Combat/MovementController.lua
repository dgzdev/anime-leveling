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
local Validate = require(ReplicatedStorage.Validate)

local ProgressionService
local StatusController

local taps = 0
local lastTap = tick()
local keys = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D }

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local LeftLeg = Character:WaitForChild("Left Leg")
		local RightLeg = Character:WaitForChild("Right Leg")
		local Humanoid = Character:WaitForChild("Humanoid")
		local RootPart = Character:WaitForChild("HumanoidRootPart")

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

	if Humanoid.WalkSpeed ~= Movement.WalkSpeed then
		Humanoid.WalkSpeed = Movement.WalkSpeed
		Humanoid.JumpPower = Movement.JumpPower

	end

	Humanoid:SetAttribute("State", state)

	CameraEvent:Fire("FOV", Movement.FOV)
end

function MovementModule:BindAttribute()
	-- Humanoid:GetAttributeChangedSignal("State"):Connect(function()
	-- 	local value = Humanoid:GetAttribute("State")
	-- 	if value then
	-- 		MovementModule:ChangeCharacterState(value)
	-- 	end
	-- end)

	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		local value = Humanoid.WalkSpeed
		if value <= StarterPlayer.CharacterWalkSpeed then
			self.CharacterProperties.CharacterState = "WALK"
		else
			if Validate:CanRun(Humanoid) then
				self.CharacterProperties.CharacterState = "RUN"
			end
		end

		local state = self.CharacterProperties.CharacterState
		local Movement = self.CharacterProperties.Movement[state]
		CameraEvent:Fire("FOV", Movement.FOV)

		Humanoid.WalkSpeed = value
	end)
end

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
						if Validate:CanRun(Humanoid) then
							MovementModule:ChangeCharacterState("RUN")
						end
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
	MovementModule:ChangeCharacterState("WALK")

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

		UserInputService.JumpRequest:Connect(function()
			if RootPart:FindFirstChildWhichIsA("AlignPosition") then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			else
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			end
		end)

		Humanoid.Jumping:Connect(function(active)
			if active then
				ef1.Enabled = false
				ef2.Enabled = false
			end
		end)
end

function MovementModule:KnitInit()
	ProgressionService = Knit.GetService("ProgressionService")
	StatusController = Knit.GetController("StatusController")

	coroutine.wrap(function()
		MovementModule:CreateBinds()
		MovementModule:CreateContextBinder()
		MovementModule:BindAttribute()
	end)()

	Player.CharacterAdded:Connect(function(character)
		Character = character
		LeftLeg = Character:WaitForChild("Left Leg")
		RightLeg = Character:WaitForChild("Right Leg")
		Humanoid = Character:WaitForChild("Humanoid")

		MovementModule:CreateBinds()
		MovementModule:CreateContextBinder()
		MovementModule:BindAttribute()
	end)
end

return MovementModule
