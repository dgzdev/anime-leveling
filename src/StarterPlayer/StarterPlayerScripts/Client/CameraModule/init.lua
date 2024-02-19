local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CameraModule = {}
CameraModule.OTS = require(ReplicatedStorage.Modules.OTS) --> OTS is a module for camera manipulation.

local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local ScrollLimits = {
	["Min"] = 4,
	["Max"] = 13,
}

function CameraModule:Init()
	repeat
		task.wait(1)
	until game:IsLoaded() == true

	-- ? Check if the OTS module is loaded.
	self:CheckCondition(self.OTS ~= nil, "[CameraModule] OTS is nil, this is a problem.")

	self:EnableCamera()
end
function CameraModule:CheckCondition(condition: true | false, message: string) --> Check if a condition is true, if not, throw an error.
	if condition == false then
		error(message)
	end
end

CameraModule.EnableCamera = function(self)
	ContextActionService:BindAction("MouseWheel", function(actionName, inputState, inputObject)
		local CameraSettings = self.OTS.CameraSettings
		local SETTINGS = self.OTS.CameraSettings["DefaultShoulder"]
		if inputObject.Position.Z == 1 then
			--> MouseWheelUp
			SETTINGS.Offset-=Vector3.new(0,0,0.5)
		else
			--> MouseWheelDown
			SETTINGS.Offset+=Vector3.new(0,0,0.5)
		end
		SETTINGS.Offset = Vector3.new(SETTINGS.Offset.X, SETTINGS.Offset.Y, math.clamp(SETTINGS.Offset.Z, ScrollLimits.Min, ScrollLimits.Max))
		CameraSettings["ZoomedShoulder"].Offset = Vector3.new(1.1, 1.4, SETTINGS.Offset.Z/2)
	end, false, Enum.UserInputType.MouseWheel)

	ContextActionService:BindAction("ZoomShoulder",  function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			self.OTS:SetActiveCameraSettings("ZoomedShoulder")
		elseif inputState == Enum.UserInputState.End then
			self.OTS:SetActiveCameraSettings("DefaultShoulder")
		end
	end, false, Enum.KeyCode.C)

	self.OTS:Enable()
end

CameraModule.DisableCamera = function(self)
	self.OTS:Disable()
end
CameraModule.OnProfileReceive = function(self) end --> Ignore, not used for this module.
CameraModule:Init()

CameraEvent.Event:Connect(function(action: string, ...)
	if action == "Enable" then
		CameraModule:EnableCamera()
	elseif action == "Disable" then
		CameraModule:DisableCamera()
	end

	if action == "Lock" then
		CameraModule.OTS:SetMouseStep(true)
	elseif action == "Unlock" then
		CameraModule.OTS:SetMouseStep(false)
	end

	if action == "FOV" then
		local FOV = ...
		CameraModule.OTS.CameraSettings.DefaultShoulder.FieldOfView = FOV
	end
end)

return CameraModule
