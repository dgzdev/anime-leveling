local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local GameDataWeapons = require(ServerStorage.GameData.Weapons)

local RenderService
local LootPoolService

local CachedDrops = {}

local DropService = Knit.CreateService({
	Name = "DropService",
	Client = {},
})


function DropService:GetDrop(prompt)
	if self:DropExist(prompt) then
		return CachedDrops[prompt]
	end
end

function DropService:DropExist(prompt)
	if CachedDrops[prompt] then
		return true
	else
		return false
	end
end

function DropService:CacheDrop(Drops, prompt)
	if not CachedDrops[prompt] then
		CachedDrops[prompt] = {
			Drops = Drops,
			prompt = prompt
		}
	end
end

function DropService:RandomDrop(AmountItems,PoolDrop)

	local t = {}
	local HighestDrop = 0
	local rarityValues = {
		["S"] = 6,
		["A"] = 5,
		["B"] = 4,
		["C"] = 3,
		["D"] = 2,
		["E"] = 1,
	}

	for i = 0, AmountItems, 1 do
		local Rank = LootPoolService:Roll(PoolDrop)
		if rarityValues[Rank] > HighestDrop then
			HighestDrop = rarityValues[Rank]
		end
		local Wps = LootPoolService:GetAllWeaponsWithRank(Rank)
		local Choosed
		local Random
		if #Wps == 1 then
			Random = 1
		end
		Choosed = Wps[Random]
		table.insert(t, Choosed)
	end

	for i,v in pairs(rarityValues) do
		if v == HighestDrop then
			HighestDrop = i
		end
	end


	return {Table = t, HDrop = HighestDrop}
end

function DropService:DropWeapon(HumanoidDied : Humanoid , Drops, HighestRank)
	local PromptPart = Instance.new("Part", workspace)
	PromptPart.Anchored = true
	PromptPart.CanCollide = false
	PromptPart.Transparency = 1
	PromptPart.Position = HumanoidDied.RootPart.CFrame.Position + Vector3.new(0,-2,0)
	local Prompt = Instance.new("ProximityPrompt", PromptPart)
	Prompt.ActionText = "Loot"
	Prompt.RequiresLineOfSight = false
	Prompt.ObjectText = "ItemName"
	Prompt.MaxActivationDistance = 25
	Prompt.HoldDuration = 1
	Prompt.Style = Enum.ProximityPromptStyle.Custom
	Prompt:SetAttribute("Theme", "Default")
    Prompt:SetAttribute("Event", "CheckLoot")
	self:CacheDrop(Drops,Prompt)
	local DropRenderData = RenderService:CreateRenderData(HumanoidDied, "DropEffects", "LootDrop", {Drops = Drops, HRank = HighestRank, Offset = HumanoidDied.RootPart.CFrame.Position + Vector3.new(0,-2,0)})
	RenderService:RenderForPlayers(DropRenderData)
end

function DropService.KnitInit()
	RenderService = Knit.GetService("RenderService")
	LootPoolService = Knit.GetService("LootPoolService")

end

return DropService