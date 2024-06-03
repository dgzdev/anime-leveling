local knit = require(game.ReplicatedStorage.Packages.Knit)

local EquipService = knit.CreateService({
	Name = "EquipService",
	Client = {},
})

function EquipService:FindEquiped(player: Player)
	local character = player.Character
	if not character then
		return
	end

	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("Equiped") then
			return tool
		end
	end

	for _, tool in ipairs(player.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:GetAttribute("Equiped") then
			return tool
		end
	end
end

function EquipService:EquipItem(player: Player, tool: Tool)
	--> tentar equipar um item
	local equiped = self:FindEquiped(player)

	if not tool:GetAttribute("Equiped") then
		tool:SetAttribute("Equiped", true)
		tool.Parent = player.Character
		tool.Name = tool:GetAttribute("Type")
		tool.Grip = tool:GetAttribute("Grip")

		if equiped then
			equiped:SetAttribute("Equiped", nil)
			equiped.Parent = player.Backpack
			equiped.Grip = CFrame.new(
				0.725000024,
				0.00200000009,
				-0.354000002,
				-0.00830843206,
				0.976898074,
				-0.213543966,
				-0.999151468,
				-0.0167251024,
				-0.0376378633,
				-0.040339902,
				0.213050067,
				0.97620815
			)
			equiped.Name = equiped:GetAttribute("Name")
		end
	end
end

function EquipService:UnequipItem() end

function EquipService:HoldItem(player: Player, tool: Tool)
	for _, v in player.Character:GetDescendants() do
		if v:IsA("Tool") and v.Name ~= tool.Name and v.Name ~= "Weapon" then
			v.Parent = player.Backpack

			if v:FindFirstChildWhichIsA("Motor6D") then
				v:FindFirstChildWhichIsA("Motor6D"):Destroy()
			end
		end
	end

	tool.Parent = player.Character
	tool.Enabled = true

	local handle = tool:FindFirstChild("Handle", true)
	if not handle then
		return
	end

	local M6 = Instance.new("Motor6D", handle)
	local I = handle:GetAttribute("Instance") or "RightHand"
	local Instance = player.Character:FindFirstChild(I, true)

	if not Instance then
		return
	end

	M6.Part0 = Instance
	M6.Part1 = handle

	M6.C0 = tool.Grip
end

return EquipService
