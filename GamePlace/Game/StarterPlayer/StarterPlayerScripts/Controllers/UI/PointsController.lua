local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PointsController = Knit.CreateController {
    Name = "PointsController"
}

local Player = game.Players.LocalPlayer
local menu = Player.PlayerGui:WaitForChild("menu")
local Background = menu:WaitForChild("Background")
local Sections = Background:WaitForChild("Sections")
local StatusMenu = Sections:WaitForChild("STATUS")
local PointsBackground = StatusMenu:WaitForChild("PointsBackground")

local ProgressionService

function PointsController:UpdateInterface(Points, PointsAvailable)
    for name, value in Points do
        PointsBackground[name].Text = name.. ": ".. tostring(value)
    end

    PointsBackground.FreePoints.Text = tostring(PointsAvailable)
end

function PointsController:BindPoints()
    for _, button: TextButton in PointsBackground:GetChildren() do
        if not button:IsA("TextButton") then
            continue
        end

        button.Text = button.Name.. ": 0"
        button.Activated:Connect(function(inputObject, clickCount)
            ProgressionService:ApplyAvailablePoint(button.Name)
        end)
    end
end

function PointsController.KnitInit()
    ProgressionService = Knit.GetService("ProgressionService")
end

function PointsController.KnitStart()
    ProgressionService.UpdatePoints:Connect(function(Points, PointsAvailable)
        PointsController:UpdateInterface(Points, PointsAvailable)
    end)

    PointsController:BindPoints()
    local Points, PointsAvailable = ProgressionService:GetPointsAndPointsAvailable(Player)
    PointsController:UpdateInterface(Points, PointsAvailable)
end

return PointsController