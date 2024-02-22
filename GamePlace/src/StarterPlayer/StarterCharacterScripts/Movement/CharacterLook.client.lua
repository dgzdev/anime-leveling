local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()

local HRP = Character:WaitForChild("HumanoidRootPart")

local Mouse = Player:GetMouse()

local OldCFrame = nil

RunService:BindToRenderStep("CharacterLook", Enum.RenderPriority.First.Value, function()
	local Camera = Workspace.CurrentCamera

	local NewCFrame =
		CFrame.new(HRP.Position, HRP.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))

	if OldCFrame ~= NewCFrame then
		local currentCFrame = HRP.CFrame
		local TargetCFrame = (
			CFrame.lookAt(
				HRP.Position,
				HRP.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
			)
		)
		HRP.CFrame = currentCFrame:Lerp(TargetCFrame, 0.25)

		OldCFrame = HRP.CFrame
	end
end)
