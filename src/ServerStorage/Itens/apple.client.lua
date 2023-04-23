local Players = game:GetService("Players")
type Item = {
    Name: string,
    Type: string,
    Amount: number | nil,
    Id: string,
}

local function GetItemData(): Item
    local Item = script.Parent
    local ItemData = {
        Name = Item.Name,
        Type = Item:GetAttribute("Type"),
        Amount = Item:GetAttribute("Amount"),
        Id = Item:GetAttribute("Id"),
    }
    return ItemData
end

-- ====================================================================================================
-- // Local
-- ====================================================================================================
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait() 
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Animator = Humanoid:WaitForChild("Animator") :: Animator

-- ====================================================================================================
-- // Data
-- ====================================================================================================
local Item = GetItemData()
local Tool = script.Parent :: Tool

-- ====================================================================================================
-- // Animations
-- ====================================================================================================

local Animations = Tool:WaitForChild("Animations") :: Folder
local Animations_Cache = Animations:GetChildren() :: {[number]: Animation}
local Animations_Store = {}

for _, value in ipairs(Animations_Cache) do
    Animations_Store[value.Name] = value
end

local Animations_Load = {} :: {[number]: Animation}
for _, Animation in pairs(Animations_Store) do
    Animations_Load[_] = Animator:LoadAnimation(Animation)
end

local function StopAnimations()
    for _, Animation in pairs(Animations_Load) do
        Animation:Stop()
    end
end

-- ====================================================================================================
-- // Variables
-- ====================================================================================================
local Cooldown = 3
local LastUse = 0

-- ====================================================================================================
-- // Module
-- ====================================================================================================

local ItemModule = {
    OnEquip = function()
        StopAnimations()
        local Base = "Equip_"
        local Key = Base..Item.Id
        local Key2 = Base..Item.Type

        local Animation = (Animations_Load[Key] or Animations_Load[Key2]) :: Animation | nil
        if Animation then
            Animation:Play()
        end
    end,
    OnUnequip = function()
        StopAnimations()
        local Base = "UnEquip_"
        local Key = Base..Item.Id
        local Key2 = Base..Item.Type

        local Animation = (Animations_Load[Key] or Animations_Load[Key2]) :: Animation | nil
        if Animation then
            Animation:Play()
        end
    end,
    OnUse = function()
        if tick() - LastUse < Cooldown then
            return
        end

        LastUse = tick()

        local Base = "Use_"
        local Key = Base..Item.Id
        local Key2 = Base..Item.Type

        local Animation = (Animations_Load[Key] or Animations_Load[Key2]) :: Animation | nil
        if Animation then
            Animation:Play()
        end
    end,
}

-- ====================================================================================================
-- // Connection
-- ====================================================================================================
Tool.Equipped:Connect(ItemModule.OnEquip)
Tool.Unequipped:Connect(ItemModule.OnUnequip)
Tool.Activated:Connect(ItemModule.OnUse)