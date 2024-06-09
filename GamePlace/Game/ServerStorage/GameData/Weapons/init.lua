local weapons = {}
local requireAndAdd = function(module)
	for i, weapon in require(module) do
		weapons[i] = weapon
	end
end

requireAndAdd(script.Sword)
requireAndAdd(script.Staff)
requireAndAdd(script.DevSpec)
requireAndAdd(script.Dagger)

return weapons
