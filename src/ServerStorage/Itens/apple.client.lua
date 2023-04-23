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

local Item = GetItemData()
local Tool = script.Parent :: Tool

local ItemModule = {
    OnEquip = function()
        
    end,
    OnUnequip = function()
        
    end,
    OnUse = function()
        print("Using "..Item.Name)
    end,
}

-- ====================================================================================================
-- // Connection
-- ====================================================================================================
Tool.Equipped:Connect(ItemModule.OnEquip)
Tool.Unequipped:Connect(ItemModule.OnUnequip)
Tool.Activated:Connect(ItemModule.OnUse)