-- ============================================================================
-- Sobrepõe as propriedades do tipo de item.
-- ============================================================================
local Items = {
    ["Apple"] = {}
}

--// Define as propriedades de acordo com o tipo de item.
local Property = {
    ["Consumable"] = {
        RequiresHandle = false,
        CanBeDropped = false,
        Grip = CFrame.new(0,-.45,.1)
    }
}

local This = {}
This.Items = Items
This.Property = Property

return This