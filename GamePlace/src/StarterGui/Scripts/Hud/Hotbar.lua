local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Hotbar = {}

local Requests = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Requests")

repeat
	task.wait(1)
until game:IsLoaded()

export type Profile = {
	Level: number,
	Experience: number,
	Gold: number,
	Equiped: {
		Weapon: string,
		Id: number,
	},

	Hotbar: { number },

	Inventory: {
		[string]: {
			AchiveDate: number,
			Id: number,
		},
	},
	Skills: { [string]: {
		AchiveDate: number | nil,
		Level: number,
	} },
	Points: {
		Inteligence: number,
		Strength: number,
		Agility: number,
		Endurance: number,
	},
}
function Hotbar:OrganizeHotbar(Profile: Profile)
	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local HotbarGui = PlayerGui:WaitForChild("UI"):WaitForChild("Hotbar")

	local fr = HotbarGui:WaitForChild("Frame")

	local hotbar = Profile.Hotbar
	local gameWeapons: { [string]: { Type: string, Damage: number } } = Requests:InvokeServer("Weapons")

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

			if itemType == "Melee" then
				local itemImage = ReplicatedStorage:WaitForChild("Models")
					:WaitForChild(itemType .. "s")
					:FindFirstChild(itemName, true) :: ImageLabel
				if not itemImage then
					continue
				end

				local itemClone = itemImage:Clone() :: ImageLabel

				itemClone.Parent = Slot
			end

			if itemType == "Sword" then
				local itemModel = ReplicatedStorage:WaitForChild("Models")
					:WaitForChild(itemType .. "s")
					:FindFirstChild(itemName, true)
				if not itemModel then
					continue
				end

				local itemClone = itemModel:Clone() :: Model

				local SlotImage = Slot:WaitForChild("SlotImage") :: ViewportFrame
				local WorldModel = SlotImage:WaitForChild("WorldModel") :: WorldModel

				WorldModel:ClearAllChildren()

				local Camera = Instance.new("Camera", SlotImage)
				SlotImage.CurrentCamera = Camera

				itemClone.Parent = WorldModel
				local Size = itemClone:GetExtentsSize().Magnitude
				local size = itemClone:GetExtentsSize()
				itemClone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(90), 0))

				Camera.FieldOfView = 80
				Camera.CameraSubject = itemClone
				Camera.CameraType = Enum.CameraType.Scriptable
				Camera.CFrame = CFrame.new(0, 1.4, (Size / 2) + 1)
				Camera.Focus = Camera.CFrame
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
	local HotbarGui = PlayerGui:WaitForChild("UI"):WaitForChild("Hotbar")

	local fr = HotbarGui:WaitForChild("Frame")

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

	print("Equiping: " .. ItemID .. " in slot: " .. slot)
	local OK = Requests:InvokeServer("Equip_Hotbar", ItemID)
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

ContextActionService:BindAction("EquipSlotItem_1", EquipSlotItem, false, Enum.KeyCode.One)
ContextActionService:BindAction("EquipSlotItem_2", EquipSlotItem, false, Enum.KeyCode.Two)
ContextActionService:BindAction("EquipSlotItem_3", EquipSlotItem, false, Enum.KeyCode.Three)
ContextActionService:BindAction("EquipSlotItem_4", EquipSlotItem, false, Enum.KeyCode.Four)

local Player = Players.LocalPlayer
Player.CharacterAdded:Connect(function(character)
	local Profile = Requests:InvokeServer("Profile")
	Hotbar:OrganizeHotbar(Profile)
end)

local Profile = Requests:InvokeServer("Profile")
Hotbar:OrganizeHotbar(Profile)

return Hotbar
