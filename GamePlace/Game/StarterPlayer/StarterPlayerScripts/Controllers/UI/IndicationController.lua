local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Source = game.ReplicatedStorage.Models.UI.DamageTemplate

local Indication = Knit.CreateController({
	Name = "Indication",
})

function Indication.BindToAllNPCS()
	local Indicator: {
		Me: Humanoid,
		Start: () -> ()
	} = {}
	Indicator.__index = Indicator

	function Indicator.new(humanoid: Humanoid)
		local self = setmetatable({}, Indicator)

		self.Me = humanoid

		return self
	end

	function Indicator:Start()
		self.Me
	end

	for __index, instance: Humanoid? in workspace:GetDescendants() do
		if instance:IsA("Humanoid") then
			local indicator = Indicator.new(instance)
			indicator:Start()
		end
	end
end

function Indication.KnitInit()
	Indication.BindToAllNPCS()
end

return Indication
