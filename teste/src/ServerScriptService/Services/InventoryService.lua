local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local PlayerService

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {
		CreateItem = Knit.CreateSignal(),
		RemoveItem = Knit.CreateSignal(),
	},
})

local GameData = require(ServerStorage.GameData)

function InventoryService:AddItem(player: Player, item: string)
	local Data = PlayerService:GetPlayerData(player)

	local lastId = 0
	for id, info in pairs(Data.Inventory) do
		lastId = info.Id
	end

	Data.Inventory[lastId + 1] = {
		Id = lastId + 1,
		Name = item,
		Amount = 1,
	}

	self.Client.CreateItem:Fire(player, item)
end

function InventoryService:RemoveItem(player: Player, item: string)
	local Data = PlayerService:GetPlayerData(player)

	local id
	for _id, info in pairs(Data.Inventory) do
		if info.Name == item then
			Data.Inventory[id] = nil
			id = _id
		end
	end

	self.Client.RemoveItem:Fire(player, {
		Name = item,
		Id = id,
	})
end

InventoryService.Equip = {}
function InventoryService.Equip:Melee() end

function InventoryService:EquipFromData(player: Player, playerData)
	local equiped = playerData.Equiped
	local weaponData = GameData.gameWeapons[equiped.Weapon]

	if not weaponData then
		return
	end

	local EquipedData = playerData.Equiped
	local Equiped = EquipedData.Weapon

	local InventoryData = GameData.gameWeapons[Equiped]
	local WeaponType = InventoryData.Type

	player:SetAttribute("WeaponType", WeaponType)
	player:SetAttribute("Equiped", Equiped)

	if WeaponType == "Sword" then
		local Model = ReplicatedStorage.Models.Swords
		local Sword = Model:FindFirstChild(Equiped)
		if not Sword then
			return error("Sword not found.")
		end

		local HaveWeaponEquiped = player.Character:FindFirstChild("Weapon")
		if HaveWeaponEquiped then
			HaveWeaponEquiped:Destroy()
		end

		local Character = player.Character or player.CharacterAdded:Wait()
		local Root = Character:WaitForChild("HumanoidRootPart")

		local Position = "RightHand"

		local SwordClone = Sword:Clone() :: Model
		SwordClone.Name = "Weapon"
		SwordClone.Parent = Character

		local RightHand = Character:WaitForChild(Position)
		SwordClone:PivotTo(RightHand:GetPivot())

		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = RightHand
		Motor6D.Part1 = SwordClone.PrimaryPart
		Motor6D.C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0))
		Motor6D.Parent = RightHand
	end

	if WeaponType == "Melee" then
		local Character = player.Character or player.CharacterAdded:Wait()
		local Weapon = Character:FindFirstChild("Weapon")
		if Weapon then
			Weapon:Destroy()
		end

		local MeleeFolder = ReplicatedStorage.Models.Melees
		local Melee = MeleeFolder:FindFirstChild(Equiped)
		if not Melee then
			return
		end
		if not Melee:IsA("Model") then
			return "OK"
		end

		local RightHand = Character:WaitForChild("Right Arm")
		local MeleeClone = Melee:Clone() :: Model
		MeleeClone.Name = "Weapon"
		MeleeClone.Parent = Character

		MeleeClone:PivotTo(
			RightHand:GetPivot() * CFrame.new(0, -1, -1.9) * CFrame.Angles(0, math.rad(180), math.rad(90))
		)

		local Weld = Instance.new("WeldConstraint")
		Weld.Parent = MeleeClone
		Weld.Part0 = RightHand
		Weld.Part1 = MeleeClone.PrimaryPart
	end

	return "OK"
end

function InventoryService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return InventoryService
