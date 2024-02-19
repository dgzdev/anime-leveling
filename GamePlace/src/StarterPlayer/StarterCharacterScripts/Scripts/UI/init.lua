local Players = game:GetService("Players")
local UI = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Events = require(script:WaitForChild("Events"))

local GuiObject = {}
GuiObject.__index = GuiObject

local Stored = {}

function GuiObject.new(object: GuiButton)
    local self = setmetatable({}, GuiObject)

    if Stored[object] then
        return
    end
    Stored[object] = true

    self.Object = object
    self.Object.Activated:Connect(function(inputObject, clickCount)
        local Event = self.Object:GetAttribute("Event")
        if Events.Buttons[Event] then
            Events.Buttons[Event](self.Object, self)
        end
    end)

    return self
end

function UI:Init()
    local function Apply(Object: GuiButton)
        if Object.ClassName:find("Button") then
            GuiObject.new(Object)
        end
    end

    for _, Object: GuiButton in ipairs(PlayerGui:GetDescendants()) do
        Apply(Object)
    end
    PlayerGui.DescendantAdded:Connect(function(descendant)
        Apply(descendant)
    end)
end

UI.OnProfileReceive = function() return end

UI:Init()
return UI