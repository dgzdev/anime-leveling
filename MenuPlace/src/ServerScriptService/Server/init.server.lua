local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
--!strict
-- Author: @SinceVoid
-- Esse é o arquivo principal do servidor, onde todos os módulos serão carregados.

-- ====================================================================================================
--// Modules
-- ====================================================================================================
local GameData = require(ServerStorage.GameData)
local ProfileService = require(ServerStorage.ProfileService)
local ProfileStore = ProfileService.GetProfileStore(GameData.profileKey, GameData.profileTemplate)

local Characters = Workspace:WaitForChild("Characters")

local Profile: { Data: GameData.PlayerData } | nil

ReplicatedStorage.Request.OnServerInvoke = function(player: Player, request: string, description: HumanoidDescription)
	repeat
		task.wait(0.1)
	until Profile

	local slot = Profile.Data.Slots[Profile.Data.Selected_Slot]

	if request == "Customization" then
		return {
			["Hair"] = { 15633971750, 10396796837, 15852318340, 6823411442 },
			["Colors"] = {},
			["Face"] = { 14579692783, 15885231323, 13533964075, 12600150456 },

			["Shirt"] = { 7730552127 },
			["Pants"] = { 11321632482 },

			["Hat"] = {},
			["Acessory"] = {},

			["BodyColors"] = {
				{ 255, 204, 153 },
			},

			["Selected"] = {
				Hair = slot.Character.Acessories[2].AssetId,
				Face = slot.Character.Acessories[1].AssetId,
				Shirt = slot.Character.Clothes.Shirt,
				Pants = slot.Character.Clothes.Pants,
				BodyColor = slot.Character.BodyColor,
			},
		}
	end

	local Humanoid = Workspace.Characters.Rig:WaitForChild("Humanoid")

	if request == "UpdateHumanoidDescription" then
		local currentDesc = Humanoid:GetAppliedDescription()
		for stringName, value in pairs(description) do
			if stringName == "Face" then
				currentDesc.FaceAccessory = value
			elseif stringName == "Hat" then
				currentDesc.HatAccessory = value
			elseif stringName == "Hair" then
				currentDesc.HairAccessory = value
			elseif stringName == "Neck" then
				currentDesc.NeckAccessory = value
			elseif stringName == "Shoulder" then
				currentDesc.ShoulderAccessory = value
			elseif stringName == "Waist" then
				currentDesc.WaistAccessory = value
			elseif stringName == "Colors" then
				currentDesc.HeadColor = Color3.fromRGB(value[1], value[2], value[3])
				currentDesc.LeftArmColor = Color3.fromRGB(value[1], value[2], value[3])
				currentDesc.LeftLegColor = Color3.fromRGB(value[1], value[2], value[3])
				currentDesc.RightArmColor = Color3.fromRGB(value[1], value[2], value[3])
				currentDesc.RightLegColor = Color3.fromRGB(value[1], value[2], value[3])
				currentDesc.TorsoColor = Color3.fromRGB(value[1], value[2], value[3])
			elseif stringName == "Shirt" then
				currentDesc.Shirt = value
			elseif stringName == "Pants" then
				currentDesc.Pants = value
			end
		end
		Humanoid:ApplyDescription(currentDesc, Enum.AssetTypeVerification.Default)
	end
end

local function OnPlayerAdded(plr: Player)
	local Rig = ReplicatedStorage.Rig:Clone()
	Rig.Parent = Workspace:WaitForChild("Characters")

	Profile = ProfileStore:LoadProfileAsync("TESTING_DATA_1", "ForceLoad")
	if not Profile then
		plr:Kick("Failed to load profile.")
		return
	end
	if not plr:IsDescendantOf(Players) then
		Profile:Release()
		return
	end

	Profile:Reconcile()

	if RunService:IsStudio() then
		Profile.Data = GameData.profileTemplate
	end

	print(Profile.Data)

	local ProfileData: GameData.PlayerData = Profile.Data
	local SelectedSlot = ProfileData["Selected_Slot"]
	local Slot = ProfileData.Slots[SelectedSlot]
	local CharacterData = Slot.Character

	local Description = Instance.new("HumanoidDescription")

	local Acessories = {}
	for _, AcessoryData in pairs(CharacterData.Acessories) do
		local v = {
			AssetId = AcessoryData.AssetId,
			Order = AcessoryData.Order,
			Puffiness = AcessoryData.Puffiness,
		}
		if AcessoryData.AccessoryType == "Hair" then
			v.AccessoryType = Enum.AccessoryType.Hair
		elseif AcessoryData.AccessoryType == "Front" then
			v.AccessoryType = Enum.AccessoryType.Front
		elseif AcessoryData.AccessoryType == "Back" then
			v.AccessoryType = Enum.AccessoryType.Back
		elseif AcessoryData.AccessoryType == "Neck" then
			v.AccessoryType = Enum.AccessoryType.Neck
		elseif AcessoryData.AccessoryType == "Shoulder" then
			v.AccessoryType = Enum.AccessoryType.Shoulder
		elseif AcessoryData.AccessoryType == "Waist" then
			v.AccessoryType = Enum.AccessoryType.Waist
		elseif AcessoryData.AccessoryType == "Face" then
			v.AccessoryType = Enum.AccessoryType.Face
		elseif AcessoryData.AccessoryType == "Hat" then
			v.AccessoryType = Enum.AccessoryType.Hat
		end
		table.insert(Acessories, v)
	end

	Description:SetAccessories(Acessories, true)

	local BodyColor = Color3.fromRGB(unpack(CharacterData.BodyColor))
	Description.HeadColor = BodyColor
	Description.LeftArmColor = BodyColor
	Description.LeftLegColor = BodyColor
	Description.RightArmColor = BodyColor
	Description.RightLegColor = BodyColor
	Description.TorsoColor = BodyColor

	Description.Shirt = CharacterData.Clothes.Shirt
	Description.Pants = CharacterData.Clothes.Pants

	for _, Character in ipairs(Characters:GetChildren()) do
		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
		Humanoid:ApplyDescription(Description, Enum.AssetTypeVerification.Default)
	end
end
local function OnPlayerRemoving(plr: Player)
	Profile:Release()
end

local Start = ReplicatedStorage:WaitForChild("Start")
Start.OnServerEvent:Connect(function(player)
	-- * Teleport Player

	local Character = Workspace.Characters:GetChildren()[1]
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	local Animator: Animator = Humanoid:WaitForChild("Animator")
	local Root: BasePart = Character:WaitForChild("HumanoidRootPart")

	Humanoid:MoveTo(Workspace.CharacterStopPosition.CFrame.Position)

	Humanoid.MoveToFinished:Wait()

	task.wait(0.35)

	Root.Anchored = true

	local anim =
		TweenService:Create(Root, TweenInfo.new(3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0.5), {
			CFrame = Workspace.CharacterPortalPosition.CFrame,
		})
	anim:Play()

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)

	anim.Completed:Wait()

	task.wait()

	if RunService:IsStudio() then
		return player:Kick("[Teleporting] You cannot teleport in studio.")
	end
	TeleportService:TeleportAsync(16437088851, { player })
end)

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)
