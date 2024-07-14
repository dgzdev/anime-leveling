local weapons = {}
local Loaded = false
local requireAndAdd = function(module)
	for i, weapon in require(module) do
		weapons[i] = weapon
	end
end

for __index, module in script:GetChildren() do
	if Loaded then break end 
	requireAndAdd(module)
end

function weapons:GetAllWeaponsWithRank(Rank)
	local finalT = {}
	for i,v in pairs(weapons) do
		if type(v) ~= "table" then continue end
		if v.DevSpec then continue end
		if v.Rarity == Rank then
			print(Rank)
			table.insert(finalT,v.Name)
		end
	end
	return finalT
end

return weapons
