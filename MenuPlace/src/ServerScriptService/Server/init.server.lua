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
		local d = {}
		d["List"] = GameData.CharacterCustomization
		d["Selected"] = slot.Character
		return d
	end

	if request == "Slots" then
		return Profile.Data
	end

	local Humanoid: Humanoid = Workspace.Characters.Rig:WaitForChild("Humanoid")

	if request == "UpdateHumanoidDescription" then
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
	end

	if request == "RotateCharacter" then
		local c: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
		c:PivotTo(c:GetPivot() * CFrame.Angles(0, math.rad(-45), 0))
		return
	end

	if request == "SaveCharacter" then
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
	end
end

local function OnPlayerAdded(plr: Player)
	local Rig = ReplicatedStorage.Rig:Clone()
	Rig.Parent = Workspace:WaitForChild("Characters")

	Profile = ProfileStore:LoadProfileAsync(tostring(plr.UserId), "ForceLoad")
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
		-- Profile.Data = GameData.profileTemplate
	end

	print(Profile.Data)

	local ProfileData: GameData.PlayerData = Profile.Data
	local SelectedSlot = ProfileData["Selected_Slot"]
	local Slot = ProfileData.Slots[SelectedSlot]
	local CharacterData = Slot.Character

	local Description = Instance.new("HumanoidDescription")
	for name, value in pairs(CharacterData) do
		if name == "Colors" then
			local BodyColor = Color3.fromRGB(unpack(value))
			Description.HeadColor = BodyColor
			Description.LeftArmColor = BodyColor
			Description.LeftLegColor = BodyColor
			Description.RightArmColor = BodyColor
			Description.RightLegColor = BodyColor
			Description.TorsoColor = BodyColor
			continue
		end
		Description[name] = value
	end

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
	local Root: BasePart = Character.PrimaryPart

	for _, anim in ipairs(Animator:GetPlayingAnimationTracks()) do
		anim:Stop(0)
	end

	Character:PivotTo(Workspace:WaitForChild("Spawn").CFrame)

	Root.Anchored = false

	Humanoid:MoveTo(Workspace.CharacterStopPosition.CFrame.Position)

	Humanoid.MoveToFinished:Wait()

	task.wait(0.06)

	Root.Anchored = true

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
