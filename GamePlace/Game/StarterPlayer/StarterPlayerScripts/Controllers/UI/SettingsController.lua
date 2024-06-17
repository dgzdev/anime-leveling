local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SettingsController = Knit.CreateController {
    Name = "SettingsController"
}

SettingsController.GetClosest = function(values: {[number]: any}, value: number)
    local closestValue = math.huge
    local closestIndex = 0
    local indexes = {}
    for index, value in values do
        table.insert(indexes, index)
    end

    for index, val in indexes do
        if math.abs(value - val) < closestValue then
            closestValue = math.abs(value - val)
            closestIndex = val
        end
    end

    return closestIndex
end

SettingsController.Data = {
    ["Shadow Quality"] = function(value: number)
        assert(value, `value is: {value} must be a number`)

        local values = {
            [0] = {
                [game.Lighting] = {
                    ["GlobalShadows"] = false,
                },
            },
            [1] = {
                [game.Lighting] = {
                    ["GlobalShadows"] = true,
                    ["ShadowSoftness"] = 0,
                },
            },
            [2] = {
                [game.Lighting] = {
                    ["GlobalShadows"] = true,
                    ["ShadowSoftness"] = 0.01,
                },
            },
            [3] = {
                [game.Lighting] = {
                    ["GlobalShadows"] = true,
                    ["ShadowSoftness"] = 0.05,
                },
            },
        }

        local closestIndex = SettingsController.GetClosest(values, value)
        local v = values[closestIndex]

        if typeof(v) == "function" then
            return SettingsController.Data[closestIndex](value)
        elseif typeof(v) == "table" then
            for object: Instance, props: {[string]: any} in v do
                for prop: string, val: any in props do
                    object[prop] = val
                end
            end
        end
    end,
    ["Lighting Quality"] = function(value: number)
        assert(value, `value is: {value} must be a number`)

    end,
    ["Reflection Quality"] = function(value: number)
        assert(value, `value is: {value} must be a number`)

    end,
}

function SettingsController:LoadSettings(SettingsFrame: Frame)
    assert(SettingsFrame, `SettingsFrame is: {typeof(SettingsFrame)} must be a Frame`)
    assert(SettingsFrame:IsA("Frame"), `SettingsFrame is: {SettingsFrame.ClassName} must be a Frame`)

    local Template: Frame = SettingsFrame:WaitForChild("Template")
    assert(Template, `Template is: {typeof(Template)} must be a Frame`)

    local ScrollingFrame: ScrollingFrame = SettingsFrame:WaitForChild("ScrollingFrame")
    assert(ScrollingFrame, `ScrollingFrame is: {typeof(ScrollingFrame)} must be a ScrollingFrame`)

    for Setting, callback in pairs(SettingsController.Data) do
        local SettingFrame: Frame = Template:Clone()
        SettingFrame.Name = Setting
        SettingFrame.Parent = ScrollingFrame

        SettingFrame.Visible = true

        local Value: NumberValue = SettingFrame:WaitForChild("Value", 1)
        assert(Value, `Value is: {typeof(Value)} must be a NumberValue`)

        local SettingName: TextLabel = SettingFrame:WaitForChild("SettingName", 1)
        assert(SettingName, `SettingName is: {typeof(SettingName)} must be a TextLabel`)

        SettingName.Text = Setting

        local Container: Frame = SettingFrame:WaitForChild("Container", 1)
        assert(Container, `Container is: {typeof(Container)} must be a Frame`)

        local SliderContainer: Frame = Container:WaitForChild("SliderContainer", 1)
        assert(SliderContainer, `SliderContainer is: {typeof(SliderContainer)} must be a Frame`)

        local Sizer: Frame = SliderContainer:WaitForChild("Sizer", 1)
        assert(Sizer, `Sizer is: {typeof(Sizer)} must be a Frame`)

        local Slider: TextButton = SliderContainer:WaitForChild("Slider", 1)
        assert(Slider, `Slider is: {typeof(Slider)} must be a TextButton`)

        Value.Changed:Connect(function()
            callback(Value.Value)
        end)
    end
end

function SettingsController.KnitInit()
    return
end

return SettingsController