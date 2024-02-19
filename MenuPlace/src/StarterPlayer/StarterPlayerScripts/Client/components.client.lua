local StarterGui = game:GetService("StarterGui")

repeat
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	task.wait(0.3)
until StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.All) == false
