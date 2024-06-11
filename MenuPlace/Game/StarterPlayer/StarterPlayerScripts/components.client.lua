local StarterGui = game:GetService("StarterGui")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

repeat
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	task.wait(0.3)
until StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.All) == false
