local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ====================================================================================================
--// Modules
-- ====================================================================================================
local GameData = require(ServerStorage.GameData)
local ProfileService = require(ServerStorage.ProfileService)
local ProfileStore = ProfileService.GetProfileStore(GameData.profileKey, GameData.profileTemplate)

local Rig = ReplicatedStorage.Rig:Clone()
Rig.Parent = Workspace:WaitForChild("Characters")
Rig:PivotTo(Workspace:WaitForChild("Spawn").CFrame)

local Knit = require(ReplicatedStorage.Packages.Knit)

local ClothingService = require(script:WaitForChild("ClothingService"))
local PlayerService = require(script:WaitForChild("PlayerService"))

Knit.Start():await()

local Characters = Workspace:WaitForChild("Characters")

local Profile: { Data: GameData.ProfileData } | nil

local serverRequests = {
	["Slots"] = function(slot, description: HumanoidDescription)
		return Profile.Data
	end,
	["Customization"] = function(slot, description: HumanoidDescription)
		local d = {}
		d["List"] = GameData.CharacterCustomization
		d["Selected"] = slot.Character
		return d
	end,
	["UpdateHumanoidDescription"] = function(slot, description: HumanoidDescription)
		local Humanoid: Humanoid = Workspace.Characters.Rig:WaitForChild("Humanoid")
		local currentDesc = Humanoid:GetAppliedDescription()

		for name, value in pairs(description) do
			if name == "Colors" then
				if typeof(value) == "table" then
					value = Color3.fromRGB(unpack(value))
				end
				currentDesc.HeadColor = value
				currentDesc.LeftArmColor = value
				currentDesc.LeftLegColor = value
				currentDesc.RightArmColor = value
				currentDesc.RightLegColor = value
				currentDesc.TorsoColor = value

				continue
			end
			currentDesc[name] = value
		end

		Humanoid:ApplyDescription(currentDesc, Enum.AssetTypeVerification.Default)
		return
	end,
	["RotateCharacter"] = function(slot, description: HumanoidDescription)
		local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		local Root: BasePart = c:WaitForChild("HumanoidRootPart")

		TweenService
			:Create(Root, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0.5), {
				CFrame = Root.CFrame * CFrame.Angles(0, math.rad(-45), 0),
			})
			:Play()
		return
	end,
	["SaveCharacter"] = function(slot, description: HumanoidDescription)
		local Humanoid: Humanoid = Workspace.Characters.Rig:WaitForChild("Humanoid")
		local HumanoidDescription = Humanoid:GetAppliedDescription()

		local d = {}

		d.Colors = {
			HumanoidDescription.HeadColor.R * 255,
			HumanoidDescription.HeadColor.G * 255,
			HumanoidDescription.HeadColor.B * 255,
		}
		d.HatAccessory = HumanoidDescription.HatAccessory
		d.FaceAccessory = HumanoidDescription.FaceAccessory
		d.HairAccessory = HumanoidDescription.HairAccessory
		d.NeckAccessory = HumanoidDescription.NeckAccessory
		d.ShouldersAccessory = HumanoidDescription.ShouldersAccessory
		d.WaistAccessory = HumanoidDescription.WaistAccessory
		d.BackAccessory = HumanoidDescription.BackAccessory
		d.Shirt = HumanoidDescription.Shirt
		d.Pants = HumanoidDescription.Pants

		slot.Character = d
		Profile:Save()
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
	TeleportService:TeleportAsync(16437088851, { player })
end)

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
