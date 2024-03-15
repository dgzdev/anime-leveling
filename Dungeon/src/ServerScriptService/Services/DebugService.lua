local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DebugService = Knit.CreateService({
	Name = "DebugService",
})

DebugService.Activated = false


function DebugService:CreatePathBetweenTwoPoints(Origin : CFrame,FinalPos : CFrame)

    local LastCFR = Origin
    local Distance 


    local debugPart = Instance.new("Part")
	debugPart.Parent = workspace
	debugPart.Anchored = true
	debugPart.Transparency = 0
	debugPart.Color = Color3.new(0,1,0)
	debugPart.CanCollide = false
	debugPart.Size = Vector3.new(1, 1, 1)
	debugPart.Name = "Origin"
	debugPart.CFrame = Origin
    debugPart.Shape = Enum.PartType.Ball
    debugPart.Material = Enum.Material.Neon

    local debugPart3 = Instance.new("Part")
	debugPart3.Parent = workspace
	debugPart3.Anchored = true
	debugPart3.Transparency = 0
	debugPart3.Color = Color3.new(0,0,1)
	debugPart3.CanCollide = false
	debugPart3.Name = "Default"
	debugPart3.Size = Vector3.new(1, 1, 1)
	debugPart3.CFrame = FinalPos



end


return DebugService
