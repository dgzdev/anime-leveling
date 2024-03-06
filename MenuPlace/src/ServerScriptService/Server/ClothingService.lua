local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService

local ClothingService = Knit.CreateService({
	Name = "ClothingService",
	Client = {},
})

--[[
    O que é necessário?
    -> salvar o número da shirt e da pants
    -> salvar a cor da shirt e da pants
    -> salvar a cor do personagem

    -> aplicar os mesmos
]]

local Rig: Model = Workspace:WaitForChild("Characters"):WaitForChild("Rig")
local RigHumanoid: Humanoid = Rig:WaitForChild("Humanoid")

function ClothingService:GetShirt(Player,ShirtNumber)
	--print(ShirtNumber)
	if ReplicatedStorage.Clothes.Shirt:FindFirstChild(tostring(ShirtNumber)) then
		local PlayerSlot = PlayerService:GetSlot(Player)
		PlayerSlot.Character.Shirt.Id = ShirtNumber
	end
	return ReplicatedStorage.Clothes.Shirt:FindFirstChild(tostring(ShirtNumber))
end

function ClothingService:SaveShirtColor(Player,CColor3)
	local PlayerSlot = PlayerService:GetSlot(Player)
	local SaveColor = CColor3:ToHex()
	PlayerSlot.Character.Shirt.Color = SaveColor
end


function ClothingService:WearShirt(ShirtFolder: Folder)
	if not Rig:FindFirstChild("Clothes") then
		local ClothesFolder = Instance.new("Folder", Rig)
		ClothesFolder.Name = "Clothes"
	end

	if not Rig:FindFirstChild("Clothes"):FindFirstChild("Shirt") then
		local PantsWearedFolder = Instance.new("Folder", Rig:FindFirstChild("Clothes"))
		PantsWearedFolder.Name = "Shirt"
	end

	Rig:FindFirstChild("Clothes"):FindFirstChild("Shirt"):ClearAllChildren()

	for i: number, v: BasePart in ipairs(ShirtFolder:GetChildren()) do
		local Clothe: BasePart = v:Clone()
		if Clothe:IsA("BasePart") then
			Clothe.Parent = Rig:FindFirstChild("Clothes"):FindFirstChild("Shirt")

			for _, Weld: Weld in ipairs(Clothe:GetDescendants()) do
				if Weld:IsA("Weld") then
					local _find = Rig:FindFirstChild(Weld.Name)
					if _find then
						Weld.Part0 = _find
					end
				end
			end
		end
	end
end

function ClothingService:GetPants(Player,PantsNumber)
	if ReplicatedStorage.Clothes.Pants:FindFirstChild(tostring(PantsNumber)) then
		local PlayerSlot = PlayerService:GetSlot(Player)
		PlayerSlot.Character.Pants.Id = PantsNumber
	end
	return ReplicatedStorage.Clothes.Pants:FindFirstChild(tostring(PantsNumber))
end

function ClothingService:SavePantsColor(Player,CColor3)
	local PlayerSlot = PlayerService:GetSlot(Player)
	local SaveColor = CColor3:ToHex()
	PlayerSlot.Character.Pants.Color = SaveColor
end

function ClothingService:WearPants(PantsFolder)
	if not Rig:FindFirstChild("Clothes") then
		local ClothesFolder = Instance.new("Folder", Rig)
		ClothesFolder.Name = "Clothes"
	end

	if not Rig:FindFirstChild("Clothes"):FindFirstChild("Pants") then
		local PantsWearedFolder = Instance.new("Folder", Rig:FindFirstChild("Clothes"))
		PantsWearedFolder.Name = "Pants"
	end

	Rig:FindFirstChild("Clothes"):FindFirstChild("Pants"):ClearAllChildren()

	for i: number, v: BasePart in ipairs(PantsFolder:GetChildren()) do
		local Clothe: BasePart = v:Clone()
		if Clothe:IsA("BasePart") then
			Clothe.Parent = Rig:FindFirstChild("Clothes"):FindFirstChild("Pants")

			for _, Weld: Weld in ipairs(Clothe:GetDescendants()) do
				if Weld:IsA("Weld") then
					local _find = Rig:FindFirstChild(Weld.Name)
					if _find then
						Weld.Part0 = _find
					end
				end
			end
		end
	end
end

function ClothingService:GetShoes(Player,ShoesNumber)
	if ReplicatedStorage.Clothes.Shoes:FindFirstChild(tostring(ShoesNumber)) then
		local PlayerSlot = PlayerService:GetSlot(Player)
		PlayerSlot.Character.Shoes.Id = ShoesNumber
	end
	return ReplicatedStorage.Clothes.Shoes:FindFirstChild(tostring(ShoesNumber))
end

function ClothingService:SaveShoesColor(Player,CColor3)
	local PlayerSlot = PlayerService:GetSlot(Player)
	local SaveColor = CColor3:ToHex()
	PlayerSlot.Character.Shoes.Color = SaveColor
end

function ClothingService:WearShoes(ShoesFolder)
	if not Rig:FindFirstChild("Clothes") then
		local ClothesFolder = Instance.new("Folder", Rig)
		ClothesFolder.Name = "Clothes"
	end

	if not Rig:FindFirstChild("Clothes"):FindFirstChild("Shoes") then
		local PantsWearedFolder = Instance.new("Folder", Rig:FindFirstChild("Clothes"))
		PantsWearedFolder.Name = "Shoes"
	end

	Rig:FindFirstChild("Clothes"):FindFirstChild("Shoes"):ClearAllChildren()

	for i: number, v: BasePart in ipairs(ShoesFolder:GetChildren()) do
		local Clothe: BasePart = v:Clone()
		if Clothe:IsA("BasePart") then
			Clothe.Parent = Rig:FindFirstChild("Clothes"):FindFirstChild("Shoes")

			for _, Weld: Weld in ipairs(Clothe:GetDescendants()) do
				if Weld:IsA("Weld") then
					local _find = Rig:FindFirstChild(Weld.Name)
					if _find then
						Weld.Part0 = _find
					end
				end
			end
		end
	end
end

function ClothingService:GetHair(Player,HairNumber)
	if ReplicatedStorage.Clothes.Hair:FindFirstChild(tostring(HairNumber)) then
		local PlayerSlot = PlayerService:GetSlot(Player)
		PlayerSlot.Character.Hair.Id = HairNumber
	end
	return ReplicatedStorage.Clothes.Hair:FindFirstChild(tostring(HairNumber))
end

function ClothingService:WearHair(HairFolder)
	if not Rig:FindFirstChild("Clothes") then
		local ClothesFolder = Instance.new("Folder", Rig)
		ClothesFolder.Name = "Clothes"
	end

	if not Rig:FindFirstChild("Clothes"):FindFirstChild("Hair") then
		local PantsWearedFolder = Instance.new("Folder", Rig:FindFirstChild("Clothes"))
		PantsWearedFolder.Name = "Hair"
	end

	Rig:FindFirstChild("Clothes"):FindFirstChild("Hair"):ClearAllChildren()

	for i: number, v: BasePart in ipairs(HairFolder:GetChildren()) do
		local Clothe: BasePart = v:Clone()
		if Clothe:IsA("BasePart") then
			Clothe.Parent = Rig:FindFirstChild("Clothes"):FindFirstChild("Hair")

			for _, Weld: Weld in ipairs(Clothe:GetDescendants()) do
				if Weld:IsA("Weld") then
					local _find = Rig:FindFirstChild(Weld.Name)
					if _find then
						Weld.Part0 = _find
					end
				end
			end
		end
	end
end

function ClothingService:SaveHairColor(Player,CColor3: Color3)
	local PlayerSlot = PlayerService:GetSlot(Player)
	local SaveColor = CColor3:ToHex()
	PlayerSlot.Character.Hair.Color = SaveColor
end

function ClothingService:ApplyCharacterColors(player: Player, Colors: { number })
	local BodyColors: BodyColors = Rig:WaitForChild("Body Colors")
	local Color = Color3.fromRGB(Colors[1], Colors[2], Colors[3])

	BodyColors.HeadColor3 = Color
	BodyColors.LeftArmColor3 = Color
	BodyColors.LeftLegColor3 = Color
	BodyColors.RightArmColor3 = Color
	BodyColors.RightLegColor3 = Color

	BodyColors.TorsoColor3 = Color

	local PlayerSlot = PlayerService:GetSlot(player)
	PlayerSlot.Character.Colors = Colors
end

function ClothingService:ApplyClothingColors(Player)
	local PlayerSlot = PlayerService:GetSlot(Player)
	--print(Colors)
	for i,v in pairs(PlayerSlot.Character) do
		if i == "Colors" then continue end
		if Rig:WaitForChild("Clothes"):FindFirstChild(i) then
			for j,k in pairs(Rig.Clothes:FindFirstChild(i):GetDescendants()) do
				if k:IsA("BasePart") and k:GetAttribute("CanColor") then
					k.Color = Color3.fromHex(v.Color)
				end
			end
		end
	end
end

function ClothingService.Client:GetClothingData(player: Player)
	local playerData = PlayerService:GetSlot(player)

	local Data = {}
	Data.Shirts = #ReplicatedStorage.Clothes.Shirt:GetChildren()
	Data.Pants = #ReplicatedStorage.Clothes.Pants:GetChildren()
	Data.Shoes = #ReplicatedStorage.Clothes.Shoes:GetChildren()
	Data.Hair = #ReplicatedStorage.Clothes.Hair:GetChildren()

	Data.Equipped = {
		Shirt = playerData.Character.Shirt.Id,
		Pants = playerData.Character.Pants.Id,
		Shoes = playerData.Character.Shoes.Id,
		Hair = playerData.Character.Hair.Id,
	}

	return Data
end

function ClothingService.Client:UpdateShirt(Player, shirtNumber: number)
	local Shirt = self.Server:GetShirt(Player,shirtNumber)
	if not Shirt then
		return false
	end
	self.Server:WearShirt(Shirt)
end

function ClothingService.Client:UpdatePants(Player, PantsNumber: number)
	local Pants = self.Server:GetPants(Player,PantsNumber)
	if not Pants then
		return false
	end
	self.Server:WearPants(Pants)
end

function ClothingService.Client:UpdateShoes(Player, ShoesNumber: number)
	local Shoes = self.Server:GetShoes(Player,ShoesNumber)
	if not Shoes then
		return false
	end
	self.Server:WearShoes(Shoes)
end

function ClothingService.Client:UpdateHair(Player, HairNumber: number)
	local Hair = self.Server:GetHair(Player,HairNumber)
	if not Hair then
		return false
	end
	self.Server:WearHair(Hair)
end

function ClothingService.Client:SaveClothingColors(Player, ClothingInfo)
	print(ClothingInfo)
	self.Server:SaveShirtColor(Player,ClothingInfo.Shirt)
	self.Server:SavePantsColor(Player,ClothingInfo.Pants)
	self.Server:SaveShoesColor(Player,ClothingInfo.Shoes)
	self.Server:SaveHairColor(Player,ClothingInfo.Hair)
end

export type CharacterData = {
	Shirt: {
		Id: number,
		Color: { number },
	},
	Pants: {
		Id: number,
		Color: { number },
	},
	Shoes: {
		Id: number,
		Color: { number },
	},
	Hair: {
		Id: number,
		Color: { number },
	},
}

function ClothingService:LoadCharacter(Player,characterData: CharacterData)
	print(Player,characterData)


	local Shirt = self:GetShirt(Player,characterData.Shirt.Id)
	--print(Shirt)
	self:WearShirt(Shirt)

	local Pants = self:GetPants(Player,characterData.Pants.Id)
	self:WearPants(Pants)

	local Shoes = self:GetShoes(Player,characterData.Shoes.Id)
	self:WearShoes(Shoes)

	local Hair = self:GetHair(Player, characterData.Hair.Id)
	self:WearHair(Hair)

	self:ApplyCharacterColors(Player,characterData.Colors)
	self:ApplyClothingColors(Player)
end

function ClothingService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return ClothingService
