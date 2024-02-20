local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ImmersiveModule = {}

local Camera = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

function ImmersiveModule:Init()
	repeat
		task.wait(1)
	until game:IsLoaded() == true

	if not (Players:GetAttribute("Loaded")) then
		Players:GetAttributeChangedSignal("Loaded"):Wait()
	end

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
