local weapons = {}
local requireAndAdd = function(module)
	for i, weapon in require(module) do
		weapons[i] = weapon
	end
end

for __index, module in script:GetChildren() do
	requireAndAdd(module)
end

return weapons
