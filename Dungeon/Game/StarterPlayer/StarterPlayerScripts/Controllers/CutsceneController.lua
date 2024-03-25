local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local CameraEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CAMERA")

local CutsceneController = Knit.CreateController({
	Name = "CutsceneController",
})

function CutsceneController.Init()
	if PlayerGui:FindFirstChild("loadingScreen") then
		PlayerGui:FindFirstChild("loadingScreen").Destroying:Wait()
	end

	ReplicatedStorage:SetAttribute("FirstTimeAnimationEnd", true)
	print("passou")

	CameraEvent:Fire("Enable")

	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Root = Character:WaitForChild("HumanoidRootPart")
	Root.Anchored = false
end

function CutsceneController:KnitStart()
	coroutine.wrap(function()
		print("Init")
		self:Init()
	end)()
end

return CutsceneController
