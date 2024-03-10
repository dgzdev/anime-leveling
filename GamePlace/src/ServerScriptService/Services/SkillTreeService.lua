local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local GameData = require(ServerStorage.GameData)

local PlayerService

local SkillTreeService = Knit.CreateService({
	Name = "SkillTreeService",
	Client = {
		UnlockedNewSkill = Knit.CreateSignal(),
	},
})

function SkillTreeService:GetAllSkills()
	local SkillsInTree = GameData.gameSkillsTree

	return SkillsInTree
end

function SkillTreeService:FindSkillInTree(SkillName)
	local SkillTree = self:GetAllSkills()

	local function FindSpecificSkill(InitialNode): GameData.TreeNode
		for name, skillInfo: GameData.TreeNode in pairs(InitialNode) do
			if skillInfo.Name == SkillName then
				return skillInfo
			end
		end
	end
end

function SkillTreeService:UnlockNewSkill(Player, SkillName)
	local SkillInfo: GameData.TreeNode = self:FindSkillInTree(SkillName)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local SkillsTreeUnlocked = PlayerData.SkillsTreeUnlocked

	if SkillsTreeUnlocked[SkillInfo.Pendencies] and PlayerData.PointsAvailable > SkillInfo.PointsToUnlock then
		table.insert(PlayerData.SkillsTreeUnlocked, SkillInfo.Name)
	end

	return SkillInfo
end

function SkillTreeService:GetUnlockedSkills(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	return PlayerData.SkillsTreeUnlocked
end

function SkillTreeService:GetAvailableSkillsToUnlock(Player)
	local PlayerData: GameData.SlotData = PlayerService:GetData(Player)
	local SkillsTreeUnlocked = PlayerData.SkillsTreeUnlocked
	local SkillTree = self:GetAllSkills()
	local ToUnlock = {}
	local FindInData

	local function ReadTree(node)
		if not node then
			return
		end
		for name, skillInfo: GameData.TreeNode in pairs(node) do
			--print(skillInfo.Name)
			if skillInfo.Pendencies == nil then
				table.insert(ToUnlock, skillInfo.Name)
				ReadTree(skillInfo.branches)
				break
			end

			if typeof(skillInfo.Pendencies) == "table" then
				local Verification = 0
				for _, PendencyName in ipairs(skillInfo.Pendencies) do
					if Verification == #skillInfo.Pendencies then
						table.insert(ToUnlock, skillInfo.Name)
						--print(skillInfo.Name, " Inserido aqui")
						ReadTree(node.branches)
						break
					end
					if SkillsTreeUnlocked[PendencyName] then
						Verification += 1
						continue
					end
				end
			end

			if not skillInfo.branches then
				continue
			end

			if not SkillsTreeUnlocked[skillInfo.Pendencies] then
				--print(SkillsTreeUnlocked)
				--print(skillInfo.Name, skillInfo.Pendencies)
				break
			end

			--print(skillInfo.Name, " Inserido aqui")
			table.insert(ToUnlock, skillInfo.Name)
			ReadTree(skillInfo.branches)
		end
	end
	ReadTree(SkillTree)

	return ToUnlock
end

function SkillTreeService.Client:GetSkillsAvailableToUnlock(Player)
	print(Player)
	return self.Server:GetAvailableSkillsToUnlock(Player)
end

function SkillTreeService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return SkillTreeService
