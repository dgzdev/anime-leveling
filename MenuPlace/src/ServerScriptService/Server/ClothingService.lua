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

function ClothingService:GetShirt(ShirtNumber)
	return ReplicatedStorage.Clothes.Shirt:FindFirstChild(tostring(ShirtNumber))
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

function ClothingService:GetPants(PantsNumber)
	return ReplicatedStorage.Clothes.Pants:FindFirstChild(tostring(PantsNumber))
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

function ClothingService:GetShoes(ShoesNumber)
	return ReplicatedStorage.Clothes.Shoes:FindFirstChild(tostring(ShoesNumber))
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

function ClothingService:ApplyCharacterColors(Colors: { number })
	local BodyColors: BodyColors = Rig:WaitForChild("Body Colors")
	local Color = Color3.fromRGB(Colors[1], Colors[2], Colors[3])

	BodyColors.HeadColor3 = Color
	BodyColors.LeftArmColor3 = Color
	BodyColors.LeftLegColor3 = Color
	BodyColors.RightArmColor3 = Color
	BodyColors.RightLegColor3 = Color

	BodyColors.TorsoColor3 = Color
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
	print("a")
	local Shirt = self.Server:GetShirt(shirtNumber)
	if not Shirt then
		return false
	end
	self.Server:WearShirt(Shirt)
end

function ClothingService.Client:UpdatePants(Player, PantsNumber: number)
	print("a")
	local Pants = self.Server:GetPants(PantsNumber)
	if not Pants then
		return false
	end
	self.Server:WearPants(Pants)
end

function ClothingService.Client:UpdateShoes(Player, ShoesNumber: number)
	print("a")
	local Shoes = self.Server:GetShoes(ShoesNumber)
	if not Shoes then
		return false
	end
	self.Server:WearShoes(Shoes)
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

function ClothingService:LoadCharacter(characterData: CharacterData)
	print(characterData)

	local Shirt = self:GetShirt(characterData.Shirt.Id)
	self:WearShirt(Shirt)

	local Pants = self:GetPants(characterData.Pants.Id)
	self:WearPants(Pants)

	local Shoes = self:GetShoes(characterData.Shoes.Id)
	self:WearShoes(Shoes)

	self:ApplyCharacterColors(characterData.Colors)
end

function ClothingService:KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return ClothingService
