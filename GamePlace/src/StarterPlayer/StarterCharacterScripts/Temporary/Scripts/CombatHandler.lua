local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local CombatHandler = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local DefaultWeapons = {}
local SpecialWeapons = {}

function CombatHandler:Init(modules)
	Player:GetAttributeChangedSignal("WeaponType"):Connect(self.WeaponTypeChanged)
	Player:GetAttributeChangedSignal("Equiped"):Connect(self.WeaponTypeChanged)

	self:Bind(Player:GetAttribute("WeaponType"), Player:GetAttribute("Equiped"))
end

function CombatHandler:RemoveAllSlots()
	local CombatGui = PlayerGui:WaitForChild("CombatGui")
	local Background: Frame = CombatGui:WaitForChild("Background")
	for _, value in ipairs(Background:GetChildren()) do
		if value:IsA("Frame") then
			if value.Name ~= "Example" then
				value:Destroy()
			end
		end
	end
end

local Replace = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
}
function CombatHandler:CreateNewSlot(button: Enum.UserInputType, attack: string)
	local CombatGui = PlayerGui:WaitForChild("CombatGui")
	local Background: Frame = CombatGui:WaitForChild("Background")

	local Slot: Frame = Background:WaitForChild("Example"):Clone()

	local buttonName = Replace[button] or button.Name

	Slot:WaitForChild("Title").Text = buttonName .. ": " .. attack
	Slot.Visible = true
	Slot.Name = attack
	Slot.Parent = Background
end

function CombatHandler:Bind(weaponType: string, weaponName: string)
	if not weaponType or not weaponName then
		return
	end
	self:RemoveAllSlots()

	local binds1 = DefaultWeapons[weaponType]
	local binds2 = SpecialWeapons[weaponName:gsub(" ", "")]

	if binds1 then
		for input: Enum.UserInputType, weapon in pairs(binds1) do
			if input.Name then
				ContextActionService:BindAction("skill_" .. input.Name, weapon.callback, true, input)
				self:CreateNewSlot(input, weapon.name)
			end
		end
	end
	if binds2 then
		for input: Enum.KeyCode, weapon in pairs(binds2) do
			if input.Name then
				ContextActionService:BindAction("skill_" .. input.Name, weapon.callback, true, input)
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
	print("Viado")
	local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)
	Knit.OnStart():await()
	print("KnitStarted client")

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
