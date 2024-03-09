local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local CombatHandler = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local DefaultWeapons = {}

local bounds = {}

local SpecialWeapons = {}

function CombatHandler:Init(modules)
	Player:GetAttributeChangedSignal("WeaponType"):Connect(self.WeaponTypeChanged)
	Player:GetAttributeChangedSignal("Equiped"):Connect(self.WeaponTypeChanged)

	self:Bind(Player:GetAttribute("WeaponType"), Player:GetAttribute("Equiped"))
end

function CombatHandler:RemoveAllSlots()
	local CombatGui = PlayerGui:WaitForChild("PlayerHud")
	local Background: Frame = CombatGui:WaitForChild("Background"):WaitForChild("CombatGui"):WaitForChild("Slots")
	for _, value in ipairs(Background:GetChildren()) do
		if value:IsA("Frame") then
			if value.Name ~= "Example" and value.Name ~= "A" then
				value:Destroy()
			end
		end
	end
end

local Replace = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
}

local Extra = {
	[Enum.UserInputType.MouseButton1] = {
		Enum.KeyCode.ButtonR2,
	},
	[Enum.UserInputType.MouseButton2] = {
		Enum.KeyCode.ButtonL2,
	},
}

function CombatHandler:CreateNewSlot(button: Enum.KeyCode | Enum.UserInputType, attack: string)
	local CombatGui = PlayerGui:WaitForChild("PlayerHud")
	local Background: Frame = CombatGui:WaitForChild("Background"):WaitForChild("CombatGui")

	local A: TextLabel = Background:WaitForChild("Slots"):WaitForChild("A")
	local Slot: Frame = Background:WaitForChild("Slots"):WaitForChild("Example"):Clone()

	local buttonName = Replace[button] or button.Name
	local title: TextLabel = Slot:WaitForChild("Title")

	local Button = title:WaitForChild("Button")
	local ButtonText: TextLabel = Button:WaitForChild("ButtonText")

	title.Text = attack
	ButtonText.Text = buttonName

	A.Text = Player:GetAttribute("Equiped")

	Slot.Visible = true
	Slot.Name = attack
	Slot.Parent = Background:WaitForChild("Slots")
end

function CombatHandler:Bind(weaponType: string, weaponName: string)
	_G.Combo = 1
	if not weaponType or not weaponName then
		return
	end
	self:RemoveAllSlots()

	local binds1 = DefaultWeapons[weaponType]
	local binds2 = SpecialWeapons[weaponName:gsub(" ", "")]

	for _, name in ipairs(bounds) do
		ContextActionService:UnbindAction(name)
		bounds[_] = nil
	end

	if binds1 then
		for input: Enum.UserInputType, weapon in pairs(binds1) do
			if input.Name then
				local extra = Extra[input] or {}
				table.insert(extra, input)
				ContextActionService:BindAction("skill_" .. input.Name, weapon.callback, true, table.unpack(extra))
				bounds[#bounds + 1] = "skill_" .. input.Name
				self:CreateNewSlot(input, weapon.name)
			end
		end
	end
	if binds2 then
		for input: Enum.KeyCode, weapon in pairs(binds2) do
			if input.Name then
				local extra = Extra[input] or {}
				table.insert(extra, input)
				ContextActionService:BindAction("skill_" .. input.Name, weapon.callback, true, table.unpack(extra))
				bounds[#bounds + 1] = "skill_" .. input.Name
				self:CreateNewSlot(input, weapon.name)
			end
		end
	end
end

function CombatHandler.WeaponTypeChanged()
	local WeaponType = Player:GetAttribute("WeaponType")
	local Equiped = Player:GetAttribute("Equiped")

	if (not WeaponType) or not Equiped then
		return
	end

	CombatHandler:Bind(WeaponType, Equiped)
end

task.spawn(function()
	local Knit = require(game.ReplicatedStorage.Packages.Knit)
	Knit.OnStart():await()

	-- Starter Weapons
	for index, weapon in ipairs(script.Parent.Weapons.Starter:GetChildren()) do
		if not weapon:IsA("ModuleScript") then
			continue
		end

		local wp = require(weapon)
		DefaultWeapons[weapon.Name] = wp
	end

	-- SpecialWeapons
	for index, weapon in ipairs(script.Parent.Weapons.Special:GetChildren()) do
		if not weapon:IsA("ModuleScript") then
			continue
		end

		local wp = require(weapon)
		SpecialWeapons[weapon.Name] = wp
	end

	local _Modules = {}

	for i, v in ipairs(script.Parent.Weapons:GetDescendants()) do
		if v:IsA("ModuleScript") then
			_Modules[v.Name] = require(v)
		end
	end

	for i, v in pairs(_Modules) do
		if v.Start then
			v.Start()
		end
	end
end)

return CombatHandler
