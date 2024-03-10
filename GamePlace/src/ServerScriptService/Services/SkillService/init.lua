local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SkillService = Knit.CreateService({
	Name = "SkillService",
})

local Skills = {}

function SkillService:CallSkill(SkillName, ...)
	local skill = Skills[string.gsub(SkillName, " ", "")]
	if skill then
		skill(...)
	end
end

function SkillService.KnitStart()
	for _, skill in ipairs(script:GetDescendants()) do
		if not skill:IsA("ModuleScript") then
			continue
		end

		Skills[skill.Name] = require(skill)
	end
end

return SkillService
