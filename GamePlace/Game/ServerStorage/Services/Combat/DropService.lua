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

function DropService:DropWeapon(HumanoidDied : Humanoid , Name : string, Rank)
	local DropRenderData = RenderService:CreateRenderData(HumanoidDied, "DropEffects", "LootDrop", {Rank = Rank, Offset = HumanoidDied.RootPart.CFrame.Position + Vector3.new(0,-2,0)})
	RenderService:RenderForPlayers(DropRenderData)
end

function DropService.KnitInit()
	RenderService = Knit.GetService("RenderService")
end

return DropService