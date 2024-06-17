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

	self.variants = variants or {
		["S"] = 2,
		["A"] = 10,
		["B"] = 30,
		["C"] = 50,
		["D"] = 65,
		["E"] = 80,
	}

	local sum = 0

	for i,v in self.variants do
		sum += v
	end

	local d = divider or sum
	self.divider = d

	return self
end

function Pool:Roll(): string
	local result: string
	repeat
		local roll = math.random(1, self.divider) / self.divider
		local rarest

		for index: string, value: number in self.variants do
			value = value / self.divider
			print(value, roll, self.divider)
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

function LootPool:Roll()

	return Pool.new():Roll()
end

function LootPool.KnitInit()
	return
end

return LootPool
