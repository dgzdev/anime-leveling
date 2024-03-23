local RunService = game:GetService("RunService")
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

function MenuCamera.Enable(self)
	RunService:UnbindFromRenderStep("MenuCamera")
	self.Camera.CameraType = Enum.CameraType.Scriptable -- Set the CameraType to scriptable

	local function MouseMove()
		Player = game.Players.LocalPlayer
		Mouse = Player:GetMouse()

		local Camera = workspace.CurrentCamera
		local XFloat = -0.5 + Mouse.X / Camera.ViewportSize.X
		local YFloat = -0.5 + Mouse.Y / Camera.ViewportSize.Y

		local CF = self.CF0
			* CFrame.fromOrientation(math.rad(self.MaxYRotation * -YFloat), math.rad(self.MaxXRotation * -XFloat), 0)

		Camera.CFrame = CF
	end

	RunService:BindToRenderStep("MenuCamera", Enum.RenderPriority.Camera.Value, MouseMove)
end

function MenuCamera.Disable(self)
	RunService:UnbindFromRenderStep("MenuCamera")
end

return MenuCamera
