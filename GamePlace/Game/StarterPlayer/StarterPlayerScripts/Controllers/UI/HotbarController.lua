local Player = game.Players.LocalPlayer
local Character = Player.Character
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local HotbarController = Knit.CreateController({
	Name = "HotbarController",
})

local Events = {}

function HotbarController.EquipHotbarItem() end

function HotbarController:BindButton(Template: TextButton)
	Events[#Events + 1] = Template.Activated:Connect(function()
		local Tool = Template.Tool.Value :: Tool
		if Tool:IsDescendantOf(Character) then
			Tool.Parent = Player.Backpack
			Tool.Enabled = false
		else
			if Character:FindFirstChildWhichIsA("Tool", true) then
				Character:FindFirstChildWhichIsA("Tool", true).Parent = Player.Backpack
			end

			Tool.Parent = Character
			Tool.Enabled = true
		end
	end)

	local isHolding
	local connection
	local duration = 0

	Template.MouseButton1Down:Connect(function()
		isHolding = true

		local Clone = Template

		task.spawn(function()
			local HotbarFrame = Player.PlayerGui.Inventory.Hotbar.Background
			local InventoryFrame =
				Player.PlayerGui.Inventory.Inventory.Background.ScrollingFrame.Equipments.InventoryTemplate

			connection = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					connection:Disconnect()
					isHolding = false
					duration = 0

					Clone.Size = UDim2.fromScale(1, 1)
					Clone.Position = UDim2.fromScale(0.5, 0.5)

					local x
					local y
					local v2 = UserInputService:GetMouseLocation()
					x, y = v2.X, v2.Y

					local nearestSlot = HotbarController:GetNearestSlot(x, y)
					if not nearestSlot then --> Arrastou pra fora de slot
						Clone.Tool.Value:SetAttribute("Hotbar", nil)

						Clone.Parent = InventoryFrame
						return
					elseif nearestSlot then --> Arrastou pra um slot
						if nearestSlot:FindFirstChildWhichIsA("TextButton") then
							local before = nearestSlot:FindFirstChildWhichIsA("TextButton")

							before.Tool.Value:SetAttribute("Hotbar", nil)
							before.Parent = InventoryFrame
						end

						Clone.Tool.Value:SetAttribute("Hotbar", tonumber(nearestSlot.Parent.Name))

						Clone.Parent = nearestSlot

						return
					end
				end
			end)

			task.delay(0.5, function()
				if isHolding then
					local Draggable: ScreenGui = Player.PlayerGui:FindFirstChild("Draggable", true)
					if not Draggable then
						return error("Draggable ScreenGui not found")
					end

					Clone.Parent = Draggable
					Clone.AnchorPoint = Vector2.new(0.5, 0.5)
					Clone.Size = UDim2.fromOffset(75, 75)
				end
			end)
		end)

		task.spawn(function()
			while isHolding == true do
				if duration > 0.5 then
					local x
					local y
					local v2 = UserInputService:GetMouseLocation()
					x, y = v2.X, v2.Y

					Clone.Position = UDim2.new(0, x, 0, y)
				end

				duration += 0.01
				task.wait()
			end
		end)
	end)
end

local Containers = {}
function HotbarController.LoadContainers()
	local HotbarFrame: Frame = Player.PlayerGui.Inventory.Hotbar.Background
	for i = 1, 9, 1 do
		local Slot = HotbarFrame:WaitForChild(tostring(i))
		local container = Slot.SlotContainer
		Containers[tonumber(Slot.Name)] = container
	end
end

function HotbarController:GetNearestSlot(x: number, y: number): Frame?
	local nearestSlot
	local nearestDistance = math.huge
	local maxDistance = 65

	for i, v: Frame in Containers do
		local abs =
			Vector2.new(v.AbsolutePosition.X + (v.AbsoluteSize.X / 2), v.AbsolutePosition.Y + (v.AbsoluteSize.Y / 2))
		local distance = (abs - Vector2.new(x, y)).Magnitude
		if distance < nearestDistance and (distance < maxDistance) then
			nearestSlot = v
			nearestDistance = distance
		end
	end

	return nearestSlot
end

function HotbarController.OnBackpackRemoved(tool: Tool)
	if tool:IsDescendantOf(Player.Backpack) then
		return
	end
	if tool:IsDescendantOf(Character) then
		return
	end

	if Events[tool] then
		for i, v in pairs(Events[tool]) do
			v:Disconnect()
		end
		Events[tool] = nil
	end
end

task.spawn(function()
	--[[
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local x
			local y
			local v2 = UserInputService:GetMouseLocation()
			x, y = v2.X, v2.Y

			local nearestSlot = HotbarController:GetNearestSlot(x, y)
			if not nearestSlot then
				return
			end

			print(nearestSlot.Parent.Name)
		end
	end)
	]]
end)

function HotbarController.OnBackpackAdded(tool: Tool)
	local HotbarFrame = Player.PlayerGui.Inventory.Hotbar.Background
	local InventoryFrame = Player.PlayerGui.Inventory.Inventory.Background.ScrollingFrame.Equipments.InventoryTemplate

	if Events[tool] then
		return
	end

	Events[tool] = {}

	Events[tool][#Events[tool] + 1] = tool.Activated:Connect(function()
		print(`{tool.Name} activated`)
	end)
	Events[tool][#Events[tool] + 1] = tool.Equipped:Connect(function()
		print(`{tool.Name} equipped`)
	end)
	Events[tool][#Events[tool] + 1] = tool.Unequipped:Connect(function()
		print(`{tool.Name} unequipped`)
	end)

	local isOnHotbar = tool:GetAttribute("Hotbar") :: number --> 1 - 9

	if isOnHotbar then
		local Slot = Player.PlayerGui.Inventory.Hotbar.Background[tostring(isOnHotbar)]
		local i = (#HotbarFrame:GetChildren() - 2) + 1

		local UITemplate = ReplicatedStorage.Models.UI.SlotItem:Clone() :: TextButton
		UITemplate.Tool.Value = tool
		UITemplate.Parent = Slot.SlotContainer
		UITemplate.itemName.Text = tool.Name

		HotbarController:BindButton(UITemplate)
	elseif not isOnHotbar then
		local i = (#InventoryFrame:GetChildren() - 1) + 1

		local UITemplate = ReplicatedStorage.Models.UI.InventorySlot:Clone()
		UITemplate.Tool.Value = tool

		UITemplate.Parent = InventoryFrame
		UITemplate.Name = i
		UITemplate.itemName.Text = tool.Name

		HotbarController:BindButton(UITemplate)
	end
end

function HotbarController:RenderHotbar()
	local InventoryFrame = Player.PlayerGui.Inventory.Inventory.Background.ScrollingFrame.Equipments.InventoryTemplate

	for i, v in pairs(InventoryFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for i, tool: Tool in pairs(Player.Backpack:GetChildren()) do
		HotbarController.OnBackpackAdded(tool)
	end

	Player.Backpack.ChildAdded:Connect(function(tool: Tool)
		HotbarController.OnBackpackAdded(tool)
	end)
end

function HotbarController:KnitStart()
	HotbarController.LoadContainers()
	self:RenderHotbar()
end

return HotbarController
