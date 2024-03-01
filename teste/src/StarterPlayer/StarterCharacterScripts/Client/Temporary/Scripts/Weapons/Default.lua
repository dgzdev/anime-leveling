local Knit = require(game.ReplicatedStorage.Packages.Knit)
local WeaponService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Default = {
	[Enum.UserInputType.MouseButton1] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			if Humanoid.WalkSpeed == 0 then
				return
			end

			if RootPart.Anchored then
				return
			end

			if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
				return
			end

			if Humanoid.Health <= 0 then
				return
			end

			print("mb1")

			WeaponService:WeaponInput("Attack", inputstate)
		end,
		name = "Attack",
	},
	[Enum.UserInputType.MouseButton2] = {
		callback = function(action, inputstate, inputobject)
			if inputstate ~= Enum.UserInputState.Begin then
				return
			end

			print("mb2")

			WeaponService:WeaponInput("Defense", inputstate)
		end,
		name = "Defense",
	},
}

function Default.Start()
	WeaponService = Knit.GetService("WeaponService")
end

return Default
