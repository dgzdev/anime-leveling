local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local SoundService = game:GetService("SoundService")

local PlayerService
local InventorySeRVICE

local Hud = Knit.CreateController({
	Name = "HudController",
})

function Hud:OrganizeHotbar(Profile)
	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local HotbarGui = PlayerGui:WaitForChild("PlayerHud"):WaitForChild("Background")

	local fr = HotbarGui:WaitForChild("PlayerHotbar")

	local hotbar = Profile.Hotbar
	local gameWeapons = PlayerService:GetWeapons()

	local Inventory = Profile.Inventory

	for HotbarNumber, ItemID in ipairs(hotbar) do
		for itemName, itemProperties in pairs(Inventory) do
			local isTheItem = itemProperties.Id == ItemID
			if not isTheItem then
				continue
			end

			local isItemEquiped = Profile.Equiped.Id == ItemID
			if isItemEquiped then
				local Slot = fr:WaitForChild("Slot" .. HotbarNumber)
				Slot:SetAttribute("Active", true)
			else
				local Slot = fr:WaitForChild("Slot" .. HotbarNumber)
				Slot:SetAttribute("Active", false)
			end

			local ItemData = gameWeapons[itemName]
			local itemType = ItemData.Type

			local Slot = fr:WaitForChild("Slot" .. HotbarNumber)
			Slot:SetAttribute("ItemID", ItemID)

			Slot.Visible = true

			local HaveModel = ReplicatedStorage.Models[itemType .. "s"][itemName]:FindFirstChildWhichIsA("Model", true)
			local HaveImage =
				ReplicatedStorage.Models[itemType .. "s"][itemName]:FindFirstChildWhichIsA("ImageLabel", true)
			if HaveModel then
				local itemClone = HaveModel:Clone() :: Model

				local SlotImage = Slot:WaitForChild("SlotImage") :: ViewportFrame
				local WorldModel = SlotImage:WaitForChild("WorldModel") :: WorldModel

				WorldModel:ClearAllChildren()

				local Camera = Instance.new("Camera", SlotImage)
				SlotImage.CurrentCamera = Camera

				itemClone.Parent = WorldModel
				local Size = itemClone:GetExtentsSize().Magnitude
				itemClone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0))

				Camera.FieldOfView = 80
				Camera.CameraSubject = itemClone
				Camera.CameraType = Enum.CameraType.Scriptable
				Camera.CFrame = CFrame.new(0, 1.4, (Size / 2) + 1)
				Camera.Focus = Camera.CFrame
			end
			if HaveImage then
				local itemClone = HaveImage:Clone() :: ImageLabel

				itemClone.Parent = Slot
			end
		end
	end
end

local function PlayErrorSound()
	local Sound = SoundService:WaitForChild("SFX"):WaitForChild("Error")
	if Sound.Playing == true then
		return
	end
	Sound:Play()
end

local function PlayEquipSound()
	local Sound = SoundService:WaitForChild("SFX"):WaitForChild("Equip")
	if Sound.Playing == true then
		return
	end
	Sound:Play()
end

local function EquipSlotItem(action: string, state, input)
	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local HotbarGui = PlayerGui:WaitForChild("PlayerHud"):WaitForChild("Background")

	local fr = HotbarGui:WaitForChild("PlayerHotbar")

	if not (state == Enum.UserInputState.Begin) then
		return
	end

	local slot = tonumber(action:split("_")[2])
	local Slot = fr:WaitForChild("Slot" .. slot)

	local ItemID = Slot:GetAttribute("ItemID")
	local Equiped = Slot:GetAttribute("Active")

	if not ItemID or (Equiped == true) then
		return PlayErrorSound()
	end

	local OK = PlayerService:EquipWeapon(ItemID)
	if not OK then
		return PlayErrorSound()
	end

	local Slots = {
		fr:WaitForChild("Slot1"),
		fr:WaitForChild("Slot2"),
		fr:WaitForChild("Slot3"),
		fr:WaitForChild("Slot4"),
	}

	for _, slotImage in ipairs(Slots) do
		if slotImage == Slot then
			continue
		end
		slotImage:SetAttribute("Active", false)
	end

	Slot:SetAttribute("Active", true)
	PlayEquipSound()
end

function Hud:BindContexts()
	ContextActionService:BindAction("EquipSlotItem_1", EquipSlotItem, false, Enum.KeyCode.One)
	ContextActionService:BindAction("EquipSlotItem_2", EquipSlotItem, false, Enum.KeyCode.Two)
	ContextActionService:BindAction("EquipSlotItem_3", EquipSlotItem, false, Enum.KeyCode.Three)
	ContextActionService:BindAction("EquipSlotItem_4", EquipSlotItem, false, Enum.KeyCode.Four)
end

function Hud:KnitInit()
	PlayerService = Knit.GetService("PlayerService")
	InventoryService = Knit.GetService("InventoryService")
end

function Hud:KnitStart()
	local Player = Players.LocalPlayer
	Player.CharacterAdded:Connect(function(character)
		local Data = PlayerService:GetData(Players.LocalPlayer)
		Hud.Data = Data

		self:OrganizeHotbar(Hud.Data)
		self:BindContexts()
	end)

	InventoryService.HotbarUpdate:Connect(function(profile)
		self:OrganizeHotbar(profile)
	end)

	local Data = PlayerService:GetData(Players.LocalPlayer)
	Hud.Data = Data

	self:OrganizeHotbar(Hud.Data)
	self:BindContexts()
end

return Hud
