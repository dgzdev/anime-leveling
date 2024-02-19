local Players = game:GetService("Players")
local NPC = {}

local Player = Players.LocalPlayer
local Menus = Player:WaitForChild("PlayerGui"):WaitForChild("Menus")
local Dialogs = Menus:WaitForChild("Dialog")

local Camera = require(script.Parent:WaitForChild("Camera"))

function NPC.OnTrigger(action: string, properties: {name: string, dialog: string})
    if action == "Talk" then
        local Dialog = properties.dialog
        local Name = properties.name

        Dialogs.Enabled = true
        local Background = Dialogs:WaitForChild("Background")
        local Text = Background:WaitForChild("Dialog")
        local Title = Background:WaitForChild("Title")

        Title.Text = Name
        Text.Text = Dialog

        Camera:EnableMouse()
    end
end

return NPC