local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SakasamaNoSekai = {}
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DramaticController

local Camera: Camera = workspace.CurrentCamera
local SFX = require(game.ReplicatedStorage.Modules.SFX)


local function easeInOutQuint(x: number): number
    return if x < 0.5 then 16 * x * x * x * x * x else 1 - math.pow(-2 * x + 2, 5) / 2
end

local Affected = false

function SakasamaNoSekai.UpsideDown(RenderData)
    if Affected then
        return
    end
    local Root = RenderData.casterHumanoid.RootPart

    local OldSubject = Camera.CameraSubject

    if Players.LocalPlayer.Character ~= RenderData.casterHumanoid.Parent then
        Affected = true
        Camera.CameraSubject = Root.Parent.Head
    end

    task.spawn(function()
        DramaticController:ShowCutsceneBars()
    end)
    task.delay(0.75, function()
        SFX:Create(RenderData.casterHumanoid.Parent, "HirakoShikai", 0, 75)
        DramaticController:ShowDialogs("Yokoso sakasama no sekai ye", 1.5)
    end)

    local oldFov = Camera.FieldOfView
    TweenService:Create(Camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = 25}):Play()
    task.wait(2)
    local factor = 0


    if Players.LocalPlayer.Character ~= RenderData.casterHumanoid.Parent then
        RunService:BindToRenderStep("UpsideDownStep", Enum.RenderPriority.Camera.Value + 1, function(dt)
            factor = math.min(1, factor + (dt / 2) )
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, math.rad(180 * easeInOutQuint(factor)))
        end)
    else
        factor = 1
    end

    task.wait(1)
    repeat
        task.wait()
    until factor == 1 
    TweenService:Create(Camera, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {FieldOfView = oldFov}):Play()
    
    task.wait(1)

    Camera.CameraSubject = OldSubject
    task.spawn(function()
        DramaticController:HideCutsceneBars()
    end)

    task.wait(25)

    if Players.LocalPlayer.Character ~= RenderData.casterHumanoid.Parent then
        local factor = 0
        RunService:UnbindFromRenderStep("UpsideDownStep")
        RunService:BindToRenderStep("ReverseUpsideDownStep", Enum.RenderPriority.Camera.Value + 1, function(dt)
            factor = math.min(1, factor + (dt / 2) )
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, 0, math.rad(180 + (180 * easeInOutQuint(factor))))
        end)

        repeat
            task.wait()
        until factor >= 1
        Affected = false
        RunService:UnbindFromRenderStep("ReverseUpsideDownStep")
    end

end


function SakasamaNoSekai.Start()
    DramaticController = Knit.GetController("DramaticController")
end

function SakasamaNoSekai.Caller(RenderData)
	local Effect = RenderData.effect

    print(RenderData)

	if SakasamaNoSekai[Effect] then
		SakasamaNoSekai[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return SakasamaNoSekai