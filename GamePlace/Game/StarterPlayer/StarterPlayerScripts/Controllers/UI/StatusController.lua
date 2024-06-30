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

function PointsController:BindPoints()
    for _, button: TextButton in PointsBackground:GetChildren() do
        if not button:IsA("TextButton") then
            continue
        end

        button.Text = button.Name.. ": 0"
        button.Activated:Connect(function(inputObject, clickCount)
            print(button.Name)
        end)
    end
end

function PointsController.KnitInit()
    
end

function PointsController.KnitStart()
    PointsController:BindPoints()
end

return PointsController