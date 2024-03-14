local Camera = {}

local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")

function Camera:EnableMouse()
    CameraEvent:Fire("Unlock")
end

function Camera:DisableMouse()
    CameraEvent:Fire("Lock")
end

return Camera