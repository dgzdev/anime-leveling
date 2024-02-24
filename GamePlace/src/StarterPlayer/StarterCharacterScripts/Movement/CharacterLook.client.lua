local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()

local HRP = Character:WaitForChild("HumanoidRootPart")

local Mouse = Player:GetMouse()

local OldCFrame = nil

local Camera = Workspace.CurrentCamera

local isShiftlockEnabled = true
ContextActionService:BindAction("ToggleShiftlock", function(action, state, input)
	if state == Enum.UserInputState.Begin then
		isShiftlockEnabled = not isShiftlockEnabled
	end
end, false, Enum.KeyCode.LeftControl)

RunService.Heartbeat:Connect(function()
	if not isShiftlockEnabled then
		return
	end
	local NewCFrame =
		CFrame.new(HRP.Position, HRP.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))

	if OldCFrame ~= NewCFrame then
		HRP.CFrame = NewCFrame

		OldCFrame = HRP.CFrame
	end
end)
