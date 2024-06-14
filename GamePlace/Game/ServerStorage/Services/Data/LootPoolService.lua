local RunService = game:GetService("RunService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local LootPool = Knit.CreateService({
	Name = "LootPoolService",
	Client = {},
})

local Pool = {}
Pool.__index = Pool
Pool.ClassName = "LootPool"

export type Chances = { [string]: number }

function Pool.new(variants: Chances, divider: number?)
	local self = setmetatable({}, Pool)

	divider = divider or 1000
	self.variants = variants
	self.divider = divider

	return self
end

function Pool:Roll(): string
	local result: string

	repeat
		local roll = math.random(1, self.divider)
		local rarest

		for index: string, value: number in self.variants do
			value = value / self.divider
			if roll <= value then
				if rarest then
					if value < self.variants[rarest] then
						rarest = index
					end
				else
					rarest = index
				end
			end
		end

		if rarest then
			result = rarest
		end

		RunService.Heartbeat:Wait()
	until result ~= nil

	return result
end

function LootPool.Create(variants: Chances, divider: number?)
	return Pool.new(variants, divider)
end

function LootPool.KnitInit()
	return
end

return LootPool
