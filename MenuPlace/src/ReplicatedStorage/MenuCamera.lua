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
	if self.Connection then
		self.Connection:Disconnect() -- Disconnect from the Mouse.Move event, if exists
	end

	self.Camera.CameraType = Enum.CameraType.Scriptable -- Set the CameraType to scriptable

	local function MouseMove()
		local XFloat = -0.5 + Mouse.X / self.Camera.ViewportSize.X
		local YFloat = -0.5 + Mouse.Y / self.Camera.ViewportSize.Y

		local CF = self.CF0
			* CFrame.fromOrientation(math.rad(self.MaxYRotation * -YFloat), math.rad(self.MaxXRotation * -XFloat), 0)

		self.Camera.CFrame = CF
	end

	self.Connection = Mouse.Move:Connect(MouseMove)

	MouseMove()
end

function MenuCamera.Disable(self)
	if self.Connection then
		self.Connection:Disconnect() -- Disconnect from the Mouse.Move event, if exists
	end
end

return MenuCamera
