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

		HotbarUpdate = Knit.CreateSignal(),
	},
})

local GameData = require(ServerStorage.GameData)

function InventoryService:AddItemToHotbar(Player, itemName, posInHotbar)
	local Data = PlayerService:GetData(Player)
	if not Data.Inventory[itemName] then
		return
	end

	if table.find(Data.Hotbar, Data.Inventory[itemName].Id) then
		if Data.Hotbar[posInHotbar] then
			local CurrentPos = table.find(Data.Hotbar, Data.Inventory[itemName].Id)
			local Target = Data.Hotbar[posInHotbar]

			--print(Data.Hotbar[posInHotbar], Data.Inventory[itemName].Id)
			Data.Hotbar[CurrentPos] = Data.Hotbar[posInHotbar]
			Data.Hotbar[posInHotbar] = Data.Inventory[itemName].Id
			--print(Data.Hotbar)
			self.Client.HotbarUpdate:Fire(Player, Data)
			return Data.Hotbar
		end
		return
	end

	--if Data.Equiped.Id == Data.Inventory[itemName].Id then
	--	return
	--end

	Data.Hotbar[posInHotbar] = Data.Inventory[itemName].Id

	return Data.Hotbar
end

function InventoryService:GetPlayerInventory(Player)
	local Data = PlayerService:GetData(Player)
	return Data.Inventory
end

function InventoryService.Client:GetPlayerInventory(player)
	return self.Server:GetPlayerInventory(player)
end

function InventoryService.Client:AddItemToHotbar(Player, itemName, posInHotbar)
	return self.Server:AddItemToHotbar(Player, itemName, posInHotbar)
end

function InventoryService:AddItem(player: Player, item: string)
	local Data = PlayerService:GetData(player)

	local lastId = 0
	for id, info in Data.Inventory do
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
	local Data = PlayerService:GetData(player)

	local id
	for _id, info in Data.Inventory do
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

function InventoryService:GetGameWeapons()
	return GameData.gameWeapons, GameData.rarity
end

function InventoryService.Client:GetGameWeapons()
	return self.Server:GetGameWeapons()
end

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

	if player.Character:FindFirstChild("weaponSupport") then
		player.Character:FindFirstChild("weaponSupport"):Destroy()
	end

	if GameData.weaponSupport[WeaponType] then
		local Torso = player.Character:FindFirstChild("Torso")
		local wpSupport = GameData.weaponSupport[WeaponType]
		local model = wpSupport.Model:Clone()

		model.Name = "weaponSupport"
		model:PivotTo(Torso.CFrame)

		local w0 = Instance.new("Motor6D", model)
		w0.Part0 = Torso
		w0.Part1 = model
		w0.C1 = wpSupport.Position

		model.Parent = player.Character
	end

	player.Character:FindFirstChild("Weapons"):ClearAllChildren()

	local names = { "weaponSupport", "HumanoidRootPart", "RightHand", "LeftHand", "HeadSubject", "RootPart" }
	for _, bp: BasePart in player.Character:GetDescendants() do
		if table.find(names, bp.Name) then
			continue
		end
		if bp:IsA("BasePart") then
			bp.Transparency = 0
		end
	end

	local m = game.ReplicatedStorage.Models[WeaponType .. "s"][Equiped]
	if m then
		if m.ClassName == "Folder" then
			for _, basePart: Folder in m:GetChildren() do
				local basePartName = basePart.Name
				local Model = basePart:GetChildren()[1]

				if Model then
					local basepart = player.Character:FindFirstChild(basePartName)
					if not basepart then
						error("Basepart not found.")
						continue
					end

					local ModelClone = Model:Clone()
					ModelClone.Parent = player.Character:FindFirstChild("Weapons")

					if ModelClone:GetAttribute("Hide") == true then
						local p: BasePart = player.Character:FindFirstChild(ModelClone.Name)
						if p then
							if p:IsA("BasePart") then
								p.Transparency = 1
							end
						end

						local cloth = player.Character:WaitForChild("Clothes"):FindFirstChild(ModelClone.Name, true)
						if cloth then
							if cloth:IsA("BasePart") then
								cloth.Transparency = 1

								for _, value: BasePart in cloth:GetDescendants() do
									if value:IsA("BasePart") then
										value.Transparency = 1
									end
								end
							end
						end
					end

					ModelClone.Name = "Weapon"

					local Motor6D = Instance.new("Motor6D")
					Motor6D.Part0 = basepart
					Motor6D.Part1 = ModelClone.PrimaryPart

					Motor6D.C1 = (
						CFrame.new(0, 0, 0) * (Model:GetAttribute("Offset") or CFrame.Angles(math.rad(90), 0, 0))
					)

					Motor6D.Parent = ModelClone
				end
			end
		end
	end

	-- adicionar a tool no character
	-- pegar o eventos no client de tool equipped,unequipped e activated
	-- dependendo do item é só deixar o model dentro da tool, como por exemplo uma poção
	-- criar o tool service, que vai receber os inputs de tools, da pra separar por tipos, como consumiveis, materiais, ferramentas, etc

	player:SetAttribute("WeaponType", WeaponType)
	player:SetAttribute("Equiped", Equiped)

	return "OK"
end

function InventoryService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return InventoryService
