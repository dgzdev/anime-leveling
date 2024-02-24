local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local RootPart
local Neck
local Humanoid
local Torso

function Bind()
	RunService:UnbindFromRenderStep("HeadRotation")

	RunService:BindToRenderStep("HeadRotation", Enum.RenderPriority.Character.Value, function()
		local CameraDirection = RootPart.CFrame:toObjectSpace(game.Workspace.CurrentCamera.CFrame).lookVector.unit
		Neck.C0 = Neck.C0:Lerp(
			CFrame.new(Neck.C0.Position)
				* CFrame.Angles(0, -math.asin(CameraDirection.x), 0)
				* CFrame.Angles(-math.pi / 2 + math.asin(math.clamp(CameraDirection.y, 0, 0.5)), 0, math.pi),
			0.15
		)
	end)
end

function HandleCharacter(Character)
	RootPart, Neck = Character:WaitForChild("HumanoidRootPart"), Character:FindFirstChild("Neck", true)
	while not Neck do
		task.wait()
		Neck = Character:FindFirstChild("Neck", true)
	end
	Humanoid = Character:WaitForChild("Humanoid")

	Bind()
end

HandleCharacter(Player.Character or Player.CharacterAdded:Wait())
Player.CharacterAdded:Connect(HandleCharacter)
