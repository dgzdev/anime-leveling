local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CharacterService = Knit.CreateService {
    Name = "CharacterService",
}
local CharacterSharedFunctions = require(game.ReplicatedStorage.CharacterSharedFunctions)
local PlayerService
local ClothingService

function CharacterService:CreatePlayerHealth(Player: Player)
    local PlayerHealth = game.ReplicatedStorage.Models.PlayerHealth:Clone()
    PlayerHealth.Parent = self.Character
    PlayerHealth.Adornee = self.Character:WaitForChild("Head")
    PlayerHealth.PlayerToHideFrom = Player


    local Name = PlayerHealth:WaitForChild("Name"):WaitForChild("PlayerName")
    Name.Text = self.Character.Name

    local Health = PlayerHealth.Health.SizeFrame
    
    local Character = Player.Character
    Character.Humanoid.HealthChanged:Connect(function(health)
        local Scale = health / self.Humanoid.MaxHealth
        local Color = Color3.fromRGB(2, 255, 150):Lerp(Color3.new(1, 0, 0), 1 - Scale)
        local Tween = TweenService:Create(
            Health,
            TweenInfo.new(0.25, Enum.EasingStyle.Cubic),
            { Size = UDim2.fromScale(Scale, 1), BackgroundColor3 = Color }
        )

        Tween:Play()
    end)
end

function CharacterService:LoadCharacter(Player: Player)
    Player:LoadCharacter()
    
    local Data = PlayerService:GetData(Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    CharacterService:ApplyHumanoidDefaultAttributes(Humanoid)

	Humanoid.MaxHealth = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)
	Humanoid.Health = math.floor(math.sqrt(100 * (Data.Points.Endurance + 1)) * 10)

    CharacterService:CreatePlayerHealth(Player)
    ClothingService:LoadCharacter(Player, Data.Character)

    Humanoid:SetAttribute("Loaded", true)
end 

function CharacterService:ApplyHumanoidDefaultAttributes(Humanoid: Humanoid)
    Humanoid:SetAttribute("WeaponEquipped", false)
    Humanoid:SetAttribute("ComboCounter", 1)
    Humanoid:SetAttribute("AttackDebounce", false)
    Humanoid:SetAttribute("Equipping", false)
    Humanoid:SetAttribute("BlockReleaseTick", 0)
    Humanoid:SetAttribute("LastAttackTick", 0)

    Humanoid:SetAttribute("DefaultJumpPower", 40)
    Humanoid:SetAttribute("DefaultWalkSpeed", 12)

    Humanoid:SetAttribute("MaxPosture", 100)
    Humanoid:SetAttribute("Posture", 0)
end

function CharacterService:UpdateWalkSpeed(Humanoid: Humanoid, newWalkspeed: number?, overwrite: string)
    local newWalkspeed = newWalkspeed or 12-- pega o walkspeed de walk
    CharacterSharedFunctions:ChangeWalkSpeed(Humanoid,newWalkspeed)
end

function CharacterService:UpdateJumpPower(Humanoid: Humanoid, newJumpPower: number?, overwrite: string)
    local newJumpPower = newJumpPower or 50-- pega o jumppower
    CharacterSharedFunctions:ChangeJumpPower(Humanoid, newJumpPower)
end

function CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid: Humanoid)
    CharacterService:UpdateWalkSpeed(Humanoid)
    CharacterService:UpdateJumpPower(Humanoid)
end

function CharacterService.KnitInit()
    PlayerService = Knit.GetService("PlayerService")
    ClothingService = Knit.GetService("ClothingService")
end

 
return CharacterService