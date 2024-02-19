local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ImmersiveModule = {}

local Camera = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

function ImmersiveModule:Init()
	repeat
		task.wait(1)
	until game:IsLoaded() == true

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Captures, false)

	self:SetMouse(false) --> Disable the mouse icon, this is a must for the immersive module.
	Camera.Event:Connect(function(action: string, props)
		if action == "Unlock" then
			self:SetMouse(true)
		elseif action == "Lock" then
			self:SetMouse(false)
		end
	end)
end

function ImmersiveModule:SetMouse(state: boolean)
	return
end

ImmersiveModule.OnProfileReceive = function(self, Profile) end --> This is a stub, it's not used.

ImmersiveModule:Init() --> Initialize the ImmersiveModule.
return ImmersiveModule
