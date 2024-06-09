local skills = {}
local requireAndAdd = function(module)
	for i, skill in require(module) do
		skills[i] = skill
	end
end

requireAndAdd(script.Sword)

return skills
