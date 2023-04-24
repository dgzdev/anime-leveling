--!strict
-- Author: @SinceVoid
-- Esse é o arquivo de inventário do servidor, onde os itens serão carregados e adicionados ao jogador.

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
local FindInChild = function(Child: Instance, Name: string): Instance | nil
    for _, Child in ipairs(Child:GetChildren()) do
        if Child.Name:lower() == Name:lower() then
            return Child
        end
        if Child.ClassName:lower() == Name:lower()  then
            return Child
        end
        if Child.Name:lower():find(Name:lower()) then
            return Child
        end
    end
    return nil
end

-- ====================================================================================================
--// Module Functions
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
        local Assets = FindInChild(ServerStorage.Assets, Id) or FindInChild(ServerStorage.Assets, Type)
        if Assets then
            for _, Asset in pairs(Assets:GetChildren()) do
                local Clone = Asset:Clone()
                Clone.Parent = Tool
            end
        end

        --// Gets Item Animations
        local Animations = FindInChild(ServerStorage.Animations, Id) or FindInChild(ServerStorage.Animations, Type)
        if Animations then
            for _, Animation in pairs(Animations:GetChildren()) do
                local Clone = Animation:Clone()
                Clone.Parent = AnimationFolder
            end
        end

        --// Checks if the Item has a Script in Storage
        local Script = FindInChild(ServerStorage.Itens, Id) or FindInChild(ServerStorage.Itens, Type)
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

-- ====================================================================================================
--// Return
-- ====================================================================================================
return Inventory