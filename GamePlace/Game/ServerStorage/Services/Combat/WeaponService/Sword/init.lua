local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local GameData = require(ServerStorage.GameData)

local Default
Sword = {
	Attack = function(...)
		Default.Attack(...)
	end,

	StrongAttack = function(...)
		Default.StrongAttack(...)
	end,
}

function Sword.Start(default)
	Default = default
end

return Sword
