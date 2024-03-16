local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local startTime = 30 :: number
local global_Billboard = workspace.Waveboard.BillboardGui :: BillboardGui
local global_Text = global_Billboard.TextLabel :: TextLabel
local EnemyService

local Wave = 1 --> Default (dont change)
local MaxWaves = 5

local WaveService = Knit.CreateService({
    Name = "WaveService",
})


function WaveService:CreateEnemys(name:string, amount: number, buffMultiplier: number)

    task.spawn(function()

        for i = 1, amount , 1 do
            local EnemyRig = ReplicatedStorage.Essentials:WaitForChild("RIG"):Clone()
            local ang = math.random(-360,360)
            EnemyRig:PivotTo(workspace.Waveboard.CFrame * CFrame.Angles(0,math.rad(ang),0))
            EnemyRig.Name = name
            EnemyService:CreateEnemy(EnemyRig,{
                damage = 25 * buffMultiplier,
                health = 50 * buffMultiplier,
                inteligence = 10,
            }) 
            task.wait(2)
        end

    end)
end


function WaveService:ManageServer(wave: number,multiplier: number)

        global_Text.Text = "CURRENT WAVE: " .. Wave .. "/" .. MaxWaves
        WaveService:CreateEnemys("Troll", wave * 2, 1.5)

        repeat
            task.wait(1)
        until #workspace.Enemies:GetChildren() == 0

        if Wave < MaxWaves then
            Wave = Wave + 1
            WaveService:ManageServer(Wave, 1.5)
        end

        if Wave >= MaxWaves then
            global_Text.Text = "RAID CLEARED, CONGRATULATIONS!"

            task.wait(5)

            for i = 60, 1, -1 do
                global_Text.Text = "PORTAL CLOSING: " .. i .. "s"
                task.wait(1)
            end

                global_Text.Text = "CLOSING..."
                TeleportService:TeleportAsync(16437088851,Players:GetPlayers())

        end
end


function WaveService:Init()
    task.spawn(function()
        for i = startTime, 1, -1 do
            global_Text.Text = "STARTING MATCH: " .. i .. "s"
            task.wait(1)
        end
        global_Text.Text = "CURRENT WAVE: " .. Wave .. "/" .. MaxWaves
        WaveService:ManageServer(1,1.5)
    end)

end

function WaveService.KnitInit()
    task.spawn(function()
     EnemyService = Knit.GetService("EnemyService")
    end)

    WaveService:Init()

end


return WaveService