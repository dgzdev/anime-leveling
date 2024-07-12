local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Rig = ReplicatedStorage.Rig:Clone()
Rig.Parent = Workspace:WaitForChild("Characters")
Rig:PivotTo(Workspace:WaitForChild("Spawn").CFrame)

-- ====================================================================================================
--// Modules
-- ====================================================================================================
local GameData = require(ServerStorage.GameData)
local ProfileService = require(ServerStorage.ProfileService)
local ProfileStore = ProfileService.GetProfileStore(GameData.profileKey, GameData.profileTemplate)

local Knit = require(ReplicatedStorage.Packages.Knit)

local ClothingService = require(script:WaitForChild("ClothingService"))
local PlayerService = require(script:WaitForChild("PlayerService"))

Knit.Start():await()

local Characters = Workspace:WaitForChild("Characters")

local Profile

local serverRequests = {
	["Slots"] = function(slot, description: HumanoidDescription)
		return Profile.Data
	end,
}

ReplicatedStorage.Request.OnServerInvoke = function(player: Player, request: string, description: HumanoidDescription)
	repeat
		task.wait(0.1)
	until Profile

	local slot = Profile.Data.Slots[Profile.Data.Selected_Slot]

	if serverRequests[request] then
		return serverRequests[request](slot, description)
	else
		return error("Invalid request.")
	end
end

local function OnPlayerAdded(plr: Player)
	Profile = PlayerService:GetProfile(plr)
end

local function OnPlayerRemoving(plr: Player) end

local Start = ReplicatedStorage:WaitForChild("Start")
Start.OnServerEvent:Connect(function(player)
	-- * Teleport Player

	local Character = Workspace.Characters:GetChildren()[1]
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	local Root: BasePart = Character.PrimaryPart

	Root.Anchored = false

	Character:PivotTo(Workspace:WaitForChild("Spawn").CFrame)

	Humanoid:MoveTo(Workspace.CharacterStopPosition.CFrame.Position)

	Humanoid.MoveToFinished:Wait()

	task.wait(0.06)

	local anim =
		TweenService:Create(Root, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.5), {
			CFrame = Workspace.CharacterPortalPosition.CFrame,
		})
	anim:Play()

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)

	anim.Completed:Wait()

	task.wait()

	if RunService:IsStudio() then
		return player:Kick("[Teleporting] You cannot teleport in studio.")
	end

	local TeleportGui = game.ReplicatedFirst:WaitForChild("LoadingScreen"):WaitForChild("loadingScreen")

	local TeleportData = {
		Tutorial = false,
	}

	local Success, error_message
	repeat
		Success, error_message = pcall(function()
			TeleportService:Teleport(16437088851, player, TeleportData, TeleportGui)
		end)
		if not Success then
			warn(error_message)
			task.wait(1)
		end
	until Success == true
end)

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
