local Events = {}

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CameraEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CAMERA")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
Knit.OnStart():await()

local PromptController = Knit.GetController("PromptController")
local QuestService = Knit.GetService("QuestService")
local ProgressionService = Knit.GetService("ProgressionService")
local SkillTreeService = Knit.GetService("SkillTreeService")
local InventoryService = Knit.GetService("InventoryService")
local MarketController = Knit.GetController("MarketController")
local Workspace = game:GetService("Workspace")

local function LockMouse(boolean: boolean)
	if boolean then
		CameraEvent:Fire("Lock")
	else
		CameraEvent:Fire("Unlock")
	end
end

local CanToggle = true
local function toggleTabGui(TabGui: ScreenGui)
	if not CanToggle then
		return
	end

	local Background: Frame = TabGui:WaitForChild("Background")

	CanToggle = false
	if TabGui.Enabled == true then
		local OriginalPosition = Background.Position
		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2),
			})
		anim:Play()
		anim.Completed:Wait()

		Background.Position = OriginalPosition

		TabGui.Enabled = false
		CanToggle = true
	elseif TabGui.Enabled == false then
		local OriginalPosition = Background.Position

		Background.Position = UDim2.fromScale(0.5, 1 + Background.Size.Y.Scale / 2)

		TabGui.Enabled = true
		local anim =
			TweenService:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Position = OriginalPosition,
			})
		anim:Play()
		anim.Completed:Wait()
		CanToggle = true
	end
end

Events.Buttons = {
	["Use"] = function(Gui: GuiButton)
		local PointType = Gui.Parent.Parent.Name

		local max = 100

		local success = ProgressionService:ApplyAvailablePoint(PointType)
		if success then
			local Size = Gui.Parent.Parent:FindFirstChild("Size", true)
			local Points = Gui.Parent.Parent:FindFirstChild("Points", true)
			local Background = Gui:FindFirstAncestor("Background") --- dc
			local PointsValue = Background:FindFirstChild("PointsValue", true)

			local text = "%c POINTS"
			PointsValue.Text = text:format(ProgressionService:GetPointsAvailable(Players.LocalPlayer) or 0)

			Points.Text = tonumber(Points.Text) + 1

			local percentage = tonumber(Points.Text) / max

			TweenService:Create(Size, TweenInfo.new(1.2), {
				Size = UDim2.fromScale(1, percentage),
			}):Play()
		end
		--print(PointType)
	end,

	["ItemClick"] = function(Gui: GuiButton) --> item
		--[[
			newItem:SetAttribute("ID", item.Id)
			newItem:SetAttribute("Name", itemName)
		]]
		local ItemName = Gui:GetAttribute("Name")
		local ItemId = Gui:GetAttribute("ID")

		local Menu_UI = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Menu_UI")
		local InventoryUI = Menu_UI:WaitForChild("Inventory")
		local Background: Frame = InventoryUI:WaitForChild("Background")

		local SlotInfo = Gui.Parent.Parent:FindFirstChild("SlotInfo")
		SlotInfo:SetAttribute("ID", ItemId)
		SlotInfo:SetAttribute("Name", ItemName)

		local Mouse = Players.LocalPlayer:GetMouse()
		local ViewportSize = Workspace.CurrentCamera.ViewportSize

		SlotInfo.Position = UDim2.fromScale(Mouse.X / ViewportSize.X, Mouse.Y / ViewportSize.Y)

		SlotInfo.Visible = not SlotInfo.Visible
		SlotInfo.Title.Text = ItemName
		SlotInfo.Info.Text = "teste"

		SlotInfo:FindFirstChild("Slots", true).Visible = false
		--> clicou no item do inventario
		-- a
	end,

	["Delete"] = function(Gui: GuiButton) --> Delete

		--> clicou pra deletar item no inventario
	end,
	["Equip"] = function(Gui: GuiButton) --> Equip
		local SlotsFrame = Gui:FindFirstChild("Slots")
		SlotsFrame.Visible = true
		--> clicou pra equipar item no inventario
	end,
	["EquipSlot"] = function(Gui: GuiButton) --> slotbutton
		local SlotInfo = Gui:FindFirstAncestor("SlotInfo")
		local ItemName = SlotInfo:GetAttribute("Name")
		local ItemId = SlotInfo:GetAttribute("ID")
		local posInHotbar = Gui:GetAttribute("Slot")

		local response = InventoryService:AddItemToHotbar(ItemName, posInHotbar)
		--> clicou no numero do slot pra equipar
	end,

	["LeftShop"] = function(Gui: GuiButton)
		MarketController.TurnLeft()
		--> item pra esquerda
	end,
	["RightShop"] = function(Gui: GuiButton)
		MarketController.TurnRight()
		--> item pra direita
	end,

	["LeaveShop"] = function(Gui: GuiButton)
		MarketController.Hide()
		--> sair da loja
	end,

	["GetSkillsAvailable"] = function(Gui: GuiButton)
		local Skills = SkillTreeService:GetSkillsAvailableToUnlock(Players.LocalPlayer)
	end,
	["Close"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorWhichIsA("ScreenGui").Enabled = false
		CameraEvent:Fire("Lock")
	end,

	["Accept_Quest"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorOfClass("ScreenGui").Enabled = false
		QuestService:AcceptQuest(game.Players.LocalPlayer)
		LockMouse(true)
	end,
	["Refuse_Quest"] = function(Gui: GuiButton)
		Gui:FindFirstAncestorOfClass("ScreenGui").Enabled = false
		QuestService:DenyQuest(game.Players.LocalPlayer)
		LockMouse(true)
	end,

	["Default"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIClick"):Play()
	end,
	["MenuGui"] = function(Gui: GuiButton)
		local Player = Players.LocalPlayer
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local TabGui = PlayerGui:WaitForChild("TabGui")
		toggleTabGui(TabGui)

		local g: ScreenGui = PlayerGui:WaitForChild("Menu_UI"):WaitForChild(Gui.Name)
		local gBackground: Frame = g:WaitForChild("Background")

		local OriginalPosition = UDim2.fromScale(0.5, 0.5)

		g.Enabled = true

		gBackground.Position = UDim2.fromScale(0.5, 1 + gBackground.Size.Y.Scale / 2)
		local a = TweenService:Create(gBackground, TweenInfo.new(0.25), {
			Position = OriginalPosition,
		})
		a:Play()
		a.Completed:Wait()
	end,
}
Events.Hover = {
	["Default"] = function(Gui: GuiButton)
		if Gui:GetAttribute("Ignore") then
			return
		end
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
	end,

	["MenuGui"] = function(Gui: GuiButton)
		SoundService:WaitForChild("SFX"):WaitForChild("UIHover"):Play()
		local UIScale = Gui:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.25), { Scale = 1.15 }):Play()
		end
	end,
}
Events.HoverEnd = {
	["MenuGui"] = function(Gui: GuiButton)
		local UIScale = Gui:FindFirstChildWhichIsA("UIScale")
		if UIScale then
			TweenService:Create(UIScale, TweenInfo.new(0.25), { Scale = 1 }):Play()
		end
	end,
}

return Events
