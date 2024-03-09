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
			print(skillInfo.Name)
			if skillInfo.Pendencies == nil then
				table.insert(ToUnlock, skillInfo.Name)
				ReadTree(skillInfo.branches)
				break
			end

			if typeof(skillInfo.Pendencies) == "table" then
				for _, PendencyName in ipairs(skillInfo.Pendencies) do
					for i,v in ipairs(SkillsTreeUnlocked) do
						if PendencyName == v then
							--print(v)
							FindInData = {}
							table.insert(FindInData, v)
						end
						break
					end
					if #FindInData < #skillInfo.Pendencies then
						break
					end
					FindInData = nil
					print(skillInfo.Name, " Inserido aqui")
					table.insert(ToUnlock, PendencyName)
					ReadTree(node.branches)
				end
			end

			if not skillInfo.branches then
				continue
			end

			for i,v in ipairs(SkillsTreeUnlocked) do
				if skillInfo.Pendencies == v then
					print(v, skillInfo.Name)
					FindInData = v
				end
				break
			end

			if FindInData == nil then
				break
			end

			print(skillInfo.Name, " Inserido aqui")
			table.insert(ToUnlock, skillInfo.Name)
			ReadTree(skillInfo.branches)
		end
	end
	ReadTree(SkillTree)

	return ToUnlock
end


function SkillTreeService.Client:GetSkillsAvailableToUnlock(Player)
	print(Player)
	return	self.Server:GetAvailableSkillsToUnlock(Player)
end


function SkillTreeService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return SkillTreeService
