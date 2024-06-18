local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local GameDataWeapons = require(ServerStorage.GameData.Weapons)

local RenderService

local DropService = Knit.CreateService({
	Name = "DropService",
	Client = {},
})

function DropService:DropWeapon(Name : string, CFrame : CFrame)
  
end

function DropService.KnitInit()
	RenderService = Knit.GetService("RenderService")
end

return DropService