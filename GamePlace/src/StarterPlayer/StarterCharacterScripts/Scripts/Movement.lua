local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local OTS = require(ReplicatedStorage.Modules.OTS)

local Events = ReplicatedStorage:WaitForChild("Events")
local CameraEvent = Events:WaitForChild("CAMERA")

local MovementModule = {
	TweenInfo = TweenInfo.new(0.5),
	MovementKeys = { Enum.KeyCode.LeftShift },
	ContextName = "ChangeCharacterState",
	CharacterProperties = {
		CharacterState = "WALK",
		Movement = {
			["WALK"] = {
				WalkSpeed = StarterPlayer.CharacterWalkSpeed,
				FOV = 60,
				JumpPower = StarterPlayer.CharacterJumpPower,
			},
			["RUN"] = {
				WalkSpeed = 23,
				FOV = 70,
				JumpPower = StarterPlayer.CharacterJumpPower,
			},
		},
	},
}

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
			self:ChangeCharacterState("RUN")
		elseif state == Enum.UserInputState.Begin and self.CharacterProperties.CharacterState == "RUN" then
			self:ChangeCharacterState("WALK")
		end
	end, false, table.unpack(self.MovementKeys))
	return self.ContextName
end

MovementModule.OnProfileReceive = function(self, Profile) end --> Not used.

Humanoid.Running:Connect(function(speed)
	if speed < 0.1 then
		MovementModule:ChangeCharacterState("WALK")
	end
end)
export type CharacterState = "RUN" | "WALK"

MovementModule:CreateContextBinder()
return MovementModule
