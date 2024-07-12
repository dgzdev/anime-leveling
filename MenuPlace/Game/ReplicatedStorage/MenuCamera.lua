local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
--[[

	:Enable() -- Enables the menu camera

	:Disable() -- Disables the menu camera

--]]

local part0 = Workspace:WaitForChild("CameraParts"):FindFirstChild("Character")

local MenuCamera = {
	Camera = workspace.CurrentCamera,
	CF0 = part0.CFrame, -- origin CFrame based on an invisible Part instance which is used to easily position the camera in Studio

	-- These max values determine how much the camera will rotate based on the mouse's position
	MaxXRotation = 10, -- Degrees, accounts for both negative and positive directions.
	MaxYRotation = 10, -- Degrees, accounts for both negative and positive directions
}

local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local mouseX = workspace.CurrentCamera.ViewportSize.X / 2
local mouseY = workspace.CurrentCamera.ViewportSize.Y / 2

function MenuCamera.SetCF(self, cf: CFrame)
	self.CF0 = cf
end

function MenuCamera.Enable(self)
	RunService:UnbindFromRenderStep("MenuCamera")
	self.Camera.CameraType = Enum.CameraType.Scriptable -- Set the CameraType to scriptable

	Player = game.Players.LocalPlayer
	Mouse = Player:GetMouse()

	RunService:BindToRenderStep("Camera", Enum.RenderPriority.Last.Value, function(dt: number)
		local Camera = workspace.CurrentCamera
		local XFloat = -0.5 + mouseX / Camera.ViewportSize.X
		local YFloat = -0.5 + mouseY / Camera.ViewportSize.Y

		local CF = self.CF0
			* CFrame.fromOrientation(math.rad(self.MaxYRotation * -YFloat), math.rad(self.MaxXRotation * -XFloat), 0)

		Camera.CFrame = Camera.CFrame:Lerp(CF, 0.1)
	end)
end

local function MouseMove()
	mouseX = Mouse.X
	mouseY = Mouse.Y
end

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		MouseMove()
	end
	if input.KeyCode == Enum.KeyCode.Thumbstick1 then
		MouseMove()
	end
end)

function MenuCamera.Disable(self)
	RunService:UnbindFromRenderStep("MenuCamera")
end

return MenuCamera
