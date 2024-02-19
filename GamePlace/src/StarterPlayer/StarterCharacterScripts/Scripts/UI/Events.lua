local Events = {}

local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")

Events.Buttons = {
    ["Close"] = function(Gui: GuiButton)
        Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
        CameraEvent:Fire("Lock")
    end
}

return Events