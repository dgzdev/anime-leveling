local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService

local SkillTreeService = Knit.CreateService({
	Name = "SkillTreeService",
	Client = {
		UnlockedNewSkill = Knit.CreateSignal(),
	},
})

function SkillTreeService:GetAllSkills()

end

function SkillTreeService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end