local items = {}
local Loaded = false
local requireAndAdd = function(module)
	for i, weapon in require(module) do
		items[i] = weapon
	end
end

for __index, module in script:GetChildren() do
	if module then continue end 
	if Loaded then break end 
	requireAndAdd(module)
end

function items:GetAllWeaponsWithRank(Rank)
	local finalT = {}
	for i,v in pairs(items) do
		if type(v) ~= "table" then continue end
		if v.DevSpec then continue end
		if v.Rarity == Rank then
			print(Rank)
			table.insert(finalT,v.Name)
		end
	end
	return finalT
end

return items
