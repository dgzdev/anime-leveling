local skills = {}
local requireAndAdd = function(module)
	for i, weapon in require(module) do
		skills[i] = weapon
	end
end

for __index, module in script:GetChildren() do
	requireAndAdd(module)
end

return skills
