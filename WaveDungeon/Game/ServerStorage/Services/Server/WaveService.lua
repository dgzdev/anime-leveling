local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local RunService = game:getService("RunService")
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
                inteligence = 25,
            })
            task.wait(1.3)
        end

    end)
end


function WaveService:SetupMap(rank: string)
    if rank == "E" then
        local Crystals = Workspace.City.Crystals:GetDescendants()
        for _,v in Crystals do
            if v:IsA("BasePart") then
                v.Color = Color3.fromRGB(239, 184, 56)
            end

            if v:IsA("PointLight") then
                v.Color = Color3.fromRGB(255, 109, 5)
            end

        end

        game.Lighting.Atmosphere.Color = Color3.fromRGB(255, 107, 1)
        game.Lighting.Atmosphere.Decay = Color3.fromRGB(255, 94, 0)
        game.Lighting.Ambient = Color3.fromRGB(255, 0, 0)

    end
end

function WaveService:ManageServer(wave: number,multiplier: number,rank: string)

        global_Text.Text = "CURRENT WAVE: " .. Wave .. "/" .. MaxWaves
        local finalBuff = 0.2
        local monster = "Goblin"
        if rank == "S" then  finalBuff = 1.5 monster = "Troll" end
        if rank == "A" then  finalBuff = 0.9 monster = "Orc" end
        if rank == "B" then  finalBuff = 0.5 monster = "Goblin" end
        if rank == "C" then  finalBuff = 0.4 monster = "Goblin" end
        if rank == "E" then  finalBuff = 0.2 monster = "Goblin" end

        print(monster)
        WaveService:CreateEnemys(monster, wave * 2, wave * finalBuff)

        repeat
            task.wait(1)
        until #workspace.Enemies:GetChildren() == 0

        if Wave < MaxWaves then
            Wave = Wave + 1
            WaveService:ManageServer(Wave, 1.5,rank)
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


local hasStarted = false
function WaveService:Init(rank: string)
    if hasStarted then return end
    hasStarted = true

    WaveService:SetupMap(rank)
    task.spawn(function()
        if rank == "S" then  MaxWaves = 25 end
        if rank == "A" then  MaxWaves = 15 end
        if rank == "B" then  MaxWaves = 10 end
        if rank == "C" then  MaxWaves = 8 end
        if rank == "E" then  MaxWaves = 5 end

        for i = startTime, 1, -1 do
            global_Text.Text = "STARTING MATCH: " .. i .. "s"
            task.wait(1)
        end
        global_Text.Text = "CURRENT WAVE: " .. Wave .. "/" .. MaxWaves
        WaveService:ManageServer(1,1.5,rank)
    end)

end

local function onPlayerAdded(player)
    local joinData = player:GetJoinData()
    if RunService:IsStudio() then
        WaveService:Init("S")
    else
        local teleportData = joinData.TeleportData
        local waveRank = teleportData.waveRank or "E"
        WaveService:Init(waveRank)
    end

end

Players.PlayerAdded:Connect(onPlayerAdded)


function WaveService.KnitInit()
    task.spawn(function()
     EnemyService = Knit.GetService("EnemyService")
    end)

end





return WaveService