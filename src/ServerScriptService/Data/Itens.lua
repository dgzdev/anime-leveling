local Items = {
    ["Apple"] = {
        RequiresHandle = false,
    }
}

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