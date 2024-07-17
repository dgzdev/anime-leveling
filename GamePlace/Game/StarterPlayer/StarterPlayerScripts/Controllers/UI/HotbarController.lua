local Player = game.Players.LocalPlayer
local Character = Player.Character
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local HotbarController = Knit.CreateController({
	Name = "HotbarController",
})

local BlockController
local HotbarService
local PlayerService
local SkillService
local isHolding

local Events = {}

function HotbarController.FireServer(...)
	HotbarService:OnFireServer(...)
end

function HotbarController.ChangeItem(tool: Tool)
	if not tool:IsDescendantOf(Character) then
		if tool:GetAttribute("Class") ~= "Skill" then
			for _, t: Tool in Character:GetDescendants() do
				if t:IsA("Tool") then
					if t == tool then
						continue
					end
					t.Parent = Player.Backpack
				end
			end

			tool.Parent = Character
		else
			if not isHolding then
				print(tool)
				SkillService:UseSkill(tool.Name, { CasterCFrame = Character:GetPivot() })
			end
		end
	else
		tool.Parent = Player.Backpack
	end
end

function HotbarController:BindButton(Template: TextButton)
	Events[#Events + 1] = Template.Activated:Connect(function()
		local Tool = Template.Tool.Value :: Tool

		HotbarController.ChangeItem(Tool)
	end)

	local connection
	local duration = 0

	Template.MouseButton1Down:Connect(function()
		local inventoryHud: ScreenGui = Player.PlayerGui.Inventory.Inventory
		if not inventoryHud.Enabled then
			return
		end

		isHolding = true

		local Clone = Template

		task.spawn(function()
			local HotbarFrame = Player.PlayerGui.Inventory.Hotbar.Background
			local InventoryFrame =
				Player.PlayerGui.Inventory.Inventory.Background.ScrollingFrame.Equipments.InventoryTemplate

			connection = UserInputService.InputEnded:Connect(function(input)
				local endInputs = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonA }
				if table.find(endInputs, input.KeyCode) or table.find(endInputs, input.UserInputType) then
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
						ContextActionService:UnbindAction(`HotbarSlot_{Clone.Tool.Value:GetAttribute("Hotbar")}`)
						Clone.Tool.Value:SetAttribute("Hotbar", nil)

						Clone.Parent = InventoryFrame
						return
					elseif nearestSlot then --> Arrastou pra um slot
						if nearestSlot:FindFirstChildWhichIsA("TextButton") then
							local before = nearestSlot:FindFirstChildWhichIsA("TextButton")

							ContextActionService:UnbindAction(`HotbarSlot_{before.Tool.Value:GetAttribute("Hotbar")}`)
							before.Tool.Value:SetAttribute("Hotbar", nil)
							before.Parent = InventoryFrame
						end

						local beforeSlot = Clone.Tool.Value:GetAttribute("Hotbar") :: number
						if beforeSlot then
							ContextActionService:UnbindAction(`HotbarSlot_{beforeSlot}`)
						end

						Clone.Tool.Value:SetAttribute("Hotbar", tonumber(nearestSlot.Parent.Name))

						Clone.Parent = nearestSlot
						nearestSlot:FindFirstAncestorWhichIsA("TextButton").Visible = true

						local tool = Clone.Tool.Value :: Tool

						local Numbers = {
							[1] = Enum.KeyCode.One,
							[2] = Enum.KeyCode.Two,
							[3] = Enum.KeyCode.Three,
							[4] = Enum.KeyCode.Four,
							[5] = Enum.KeyCode.Five,
							[6] = Enum.KeyCode.Six,
							[7] = Enum.KeyCode.Seven,
							[8] = Enum.KeyCode.Eight,
							[9] = Enum.KeyCode.Nine,
						}

						local isOnHotbar = tool:GetAttribute("Hotbar") :: number --> 1 - 9
						if isOnHotbar then
							ContextActionService:UnbindAction(`HotbarSlot_{isOnHotbar}`)
							ContextActionService:BindAction(
								`HotbarSlot_{isOnHotbar}`,
								function(action, inputState, object)
									if not (inputState == Enum.UserInputState.Begin) then
										return Enum.ContextActionResult.Pass
									end

									HotbarController.ChangeItem(tool)
								end,
								false,
								Numbers[isOnHotbar]
							)
						end

						return
					end
				end
			end)

			local Draggable: ScreenGui = Player.PlayerGui:FindFirstChild("Draggable", true)
			if not Draggable then
				return error("Draggable ScreenGui not found")
			end

			Clone.Parent = Draggable
			Clone.AnchorPoint = Vector2.new(0.5, 0.5)

			local ScreenPixelX = 1920
			local ScreenPixelY = 1080

			local screenX, screenY = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
			local resizeX = screenX / ScreenPixelX
			local resizeY = screenY / ScreenPixelY

			Clone.Size = UDim2.fromOffset(75 * resizeX, 75 * resizeY)
		end)

		task.spawn(function()
			while isHolding == true do
				local x
				local y
				local v2 = UserInputService:GetMouseLocation()
				x, y = v2.X, v2.Y

				Clone.Position = UDim2.new(0, x, 0, y)

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

function HotbarController.OnBackpackAdded(tool: Tool)
	local HotbarFrame = Player.PlayerGui:WaitForChild("Inventory"):WaitForChild("Hotbar"):WaitForChild("Background")
	local InventoryFrame = Player.PlayerGui
		:WaitForChild("Inventory")
		:WaitForChild("Inventory")
		:WaitForChild("Background")
		:WaitForChild("ScrollingFrame")
		:WaitForChild("Equipments")
		:WaitForChild("InventoryTemplate")

	local Numbers = {
		[1] = Enum.KeyCode.One,
		[2] = Enum.KeyCode.Two,
		[3] = Enum.KeyCode.Three,
		[4] = Enum.KeyCode.Four,
		[5] = Enum.KeyCode.Five,
		[6] = Enum.KeyCode.Six,
		[7] = Enum.KeyCode.Seven,
		[8] = Enum.KeyCode.Eight,
		[9] = Enum.KeyCode.Nine,
	}

	local isOnHotbar = tool:GetAttribute("Hotbar") :: number --> 1 - 9
	if isOnHotbar then
		ContextActionService:UnbindAction(`HotbarSlot_{isOnHotbar}`)
		ContextActionService:BindAction(`HotbarSlot_{isOnHotbar}`, function(action, inputState, object)
			if not (inputState == Enum.UserInputState.Begin) then
				return Enum.ContextActionResult.Pass
			end

			HotbarController.ChangeItem(tool)
		end, false, Numbers[isOnHotbar])
	end

	if Events[tool] then
		return
	end

	Events[tool] = {}

	local UITemplate

	if isOnHotbar then
		local Slot = Player.PlayerGui.Inventory.Hotbar.Background[tostring(isOnHotbar)]
		local i = (#HotbarFrame:GetChildren() - 2) + 1

		UITemplate = ReplicatedStorage.Models.UI.SlotItem:Clone() :: TextButton
		UITemplate.Tool.Value = tool
		UITemplate.Parent = Slot.SlotContainer
		UITemplate.itemName.Text = tool:GetAttribute("DisplayName") or tool.Name

		tool:GetAttributeChangedSignal("DisplayName"):Connect(function()
			UITemplate.itemName.Text = tool:GetAttribute("DisplayName") or tool.Name
		end)

		Slot.Visible = true

		HotbarController:BindButton(UITemplate)
	elseif not isOnHotbar then
		local i = (#InventoryFrame:GetChildren() - 1) + 1

		UITemplate = ReplicatedStorage.Models.UI.InventorySlot:Clone()
		UITemplate.Tool.Value = tool

		UITemplate.Parent = InventoryFrame
		UITemplate.Name = i
		UITemplate.itemName.Text = tool:GetAttribute("DisplayName") or tool.Name

		tool:GetAttributeChangedSignal("DisplayName"):Connect(function()
			UITemplate.itemName.Text = tool:GetAttribute("DisplayName") or tool.Name
		end)

		HotbarController:BindButton(UITemplate)
	end

	Events[tool][#Events[tool] + 1] = tool.Activated:Connect(function()
		HotbarService:OnFireServer("Activate", { CasterCFrame = Character:GetPivot() })
	end)
	Events[tool][#Events[tool] + 1] = tool.Equipped:Connect(function()
		local isActivated = UITemplate:FindFirstChild("IsActivated") :: UIStroke
		if isActivated then
			isActivated.Enabled = true
		end

		HotbarService:OnFireServer("Equip", tool)

		if tool:GetAttribute("Class") == "Weapon" then
			BlockController:BindBlock()
		end
	end)
	Events[tool][#Events[tool] + 1] = tool.Unequipped:Connect(function()
		local isActivated = UITemplate:FindFirstChild("IsActivated") :: UIStroke
		if isActivated then
			isActivated.Enabled = false
		end

		task.spawn(function() --> POR ALGUM MOTIVO ALGO QUE TA AQUI DENTRO YIELDA O CODIGO
			HotbarService:OnFireServer("Unequip", tool)

			if tool:GetAttribute("Class") == "Weapon" then
				BlockController:UnbindBlock()
			end
		end)
	end)
end

function HotbarController:RenderHotbar()
	local InventoryFrame = Player.PlayerGui
		:WaitForChild("Inventory")
		:WaitForChild("Inventory")
		:WaitForChild("Background")
		:WaitForChild("ScrollingFrame")
		:WaitForChild("Equipments")
		:WaitForChild("InventoryTemplate")

	HotbarService:RenderItems(Player)

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

	Player.Backpack.ChildRemoved:Connect(function(tool: Tool)
		HotbarController.OnBackpackRemoved(tool)
	end)
end

function HotbarController.KnitStart()
	HotbarService = Knit.GetService("HotbarService")
	BlockController = Knit.GetController("BlockController")
	PlayerService = Knit.GetService("PlayerService")
	SkillService = Knit.GetService("SkillService")

	Player.CharacterAdded:Connect(function(char)
		Character = char
		HotbarController:RenderHotbar()
		HotbarController.LoadContainers()
	end)

	HotbarController.LoadContainers()
	HotbarController:RenderHotbar()
end

return HotbarController
