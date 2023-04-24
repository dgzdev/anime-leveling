local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Inventory = {}

-- ====================================================================================================
--// Data
-- ====================================================================================================
local Bindables = require(ServerScriptService.Data.Bindables)
local Useful = require(ServerScriptService.Data.Useful)
local ItemData = require(ServerScriptService.Data.Itens)

-- ====================================================================================================
-- // Types
-- ====================================================================================================
type Inventory = {
    [string] : {
        Name: string,
        Type: string,
        Amount: number | nil,
        Id: string,
    }
}
type Item = {
    Name: string,
    Type: string,
    Amount: number | nil,
    Id: string,
}

-- ====================================================================================================
--// Functions
-- ====================================================================================================
function Inventory.OnLoad(Player: Player, Profile: {[string]: any})
    local PlayerInv = Profile.Inventory :: Inventory

    for _, Item in pairs(PlayerInv) do
        local Amount = Item.Amount
        local Name = Item.Name
        local Type = Item.Type
        local Id = string.lower(Item.Id)

        local Tool = Instance.new("Tool")
        Tool.Name = Name
        Tool:SetAttribute("Type", Type)
        Tool:SetAttribute("Amount", Amount)
        Tool:SetAttribute("Id", Id)
        Tool.Parent = Player.Backpack

        local AnimationFolder = Instance.new("Folder", Tool)
        AnimationFolder.Name = "Animations"

        --// Set Default Properties for Item Type, and specific properties for Item Name
        local ItemNameData = ItemData.Items[Name] or {}
        local TypeData = ItemData.Property[Type] or {}

        for Property, Value in pairs(TypeData) do
            Tool[Property] = Value
        end
        for Property, Value in pairs(ItemNameData) do
            Tool[Property] = Value
        end

        --// Find for assets of the Item
        local Assets = ServerStorage.Assets:FindFirstChild(Id) or ServerStorage.Assets:FindFirstChild(Type)
        if Assets then
            for _, Asset in pairs(Assets:GetChildren()) do
                local Clone = Asset:Clone()
                Clone.Parent = Tool
            end
        end

        --// Gets Item Animations
        local Animations = ServerStorage.Animations:FindFirstChild(Id) or ServerStorage.Animations:FindFirstChild(Type)
        if Animations then
            for _, Animation in pairs(Animations:GetChildren()) do
                local Clone = Animation:Clone()
                Clone.Parent = AnimationFolder
            end
        end

        --// Checks if the Item has a Script in Storage
        local Script = ServerStorage.Itens:FindFirstChild(Id)
        if Script then
            local Clone = Script:Clone()
            Clone.Parent = Tool
            Clone:SetAttribute("Tick", tick())
        end
        
    end
end

-- ====================================================================================================
--// Connections
-- ====================================================================================================
Bindables.Profile_Load.Event:Connect(Inventory.OnLoad)

return Inventory