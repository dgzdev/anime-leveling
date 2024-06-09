local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerService

local WeaponService = Knit.CreateService({
	Name = "WeaponService",
	Client = {},
})

local DebounceService
local CharacterService
local HotbarService
local InventoryService
local AnimationService

local GameData = require(ServerStorage.GameData)
local Validate = require(game.ReplicatedStorage.Validate)
local SharedCharacterFuncitons = require(game.ReplicatedStorage.CharacterSharedFunctions)

local Weapons = {}

function WeaponService:IncreaseComboCounter(Humanoid: Humanoid)
	local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)

	if Humanoid:GetAttribute("ComboCounter") < #AnimationsFolder.Hit:GetChildren() then
		Humanoid:SetAttribute("ComboCounter", Humanoid:GetAttribute("ComboCounter") + 1)
	else
		DebounceService:AddDebounce(Humanoid, "ComboDebounce", 2)
		Humanoid:SetAttribute("ComboCounter", 1)
	end
end

function WeaponService:Stun(Character: Model, Position: Vector3, Duration: number)
	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Attachment0 = Character.PrimaryPart.RootAttachment
	AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	AlignPosition.MaxVelocity = math.huge
	AlignPosition.MaxForce = math.huge
	AlignPosition.Name = "FlashStrikeAlignPosition"
	AlignPosition.Responsiveness = 10
	-- AlignPosition.RigidityEnabled = true
	AlignPosition.Position = Position
	AlignPosition.Parent = Character.PrimaryPart
	Debris:AddItem(AlignPosition, Duration)
end

function WeaponService:Block(Character: Model, state: boolean)
	local Humanoid = Character.Humanoid
	if state then
		if not Validate:CanBlock(Humanoid) then
			Humanoid:SetAttribute("Block", false)
			return
		end

		Humanoid:SetAttribute("State", "WALK")
		-- SharedCharacterFuncitons:ChangeWalkSpeed(Humanoid, 5, "Block")

		task.delay(0.25, function()
			Humanoid:SetAttribute("BlockEndLag", false)
		end)

		local Animations = AnimationService:GetWeaponAnimationFolder(Humanoid)
		local BlockAnimation = Humanoid.Animator:LoadAnimation(Animations.Block)
		AnimationService:StopAllAnimations(Humanoid)
		BlockAnimation:Play()

		Humanoid:SetAttribute("BlockEndLag", true)
		Humanoid:SetAttribute("Block", true)
		DebounceService:AddDebounce(Humanoid, "DeflectTime", 0.25, true)
		Humanoid:SetAttribute("BlockDebounce", true)

		task.delay(0.5, function()
			Humanoid:SetAttribute("BlockDebounce", false)
		end)
	else
		repeat
			task.wait()
		until Humanoid:GetAttribute("BlockEndLag") == false
		AnimationService:StopAnimationMatch(Humanoid, "Block")
		Humanoid:SetAttribute("BlockReleaseTick", tick())
		Humanoid:SetAttribute("Block", false)
	end
end
function WeaponService.Client:Block(Player: Player, state: boolean)
	self.Server:Block(Player.Character, state)
end

function WeaponService:WeaponInput(Character: Model, ActionName: string, Data: { [any]: any })
	local Humanoid = Character.Humanoid

	local WeaponType = Humanoid:GetAttribute("WeaponType")
	local WeaponName = Humanoid:GetAttribute("WeaponName")
	local WeaponTypeModule = Weapons[WeaponType]
	local WeaponNameModule = Weapons[WeaponName]

	if WeaponNameModule and WeaponNameModule[ActionName] then
		WeaponNameModule[ActionName](Character, Data)
		return
	end

	if WeaponTypeModule and WeaponTypeModule[ActionName] then
		WeaponTypeModule[ActionName](Character, Data)
		return
	end

	if Weapons.Default[ActionName] then
		Weapons.Default[ActionName](Character, Data)
	end
end

function WeaponService.Client:WeaponInput(Player: Player, ActionName: string, Data: { [any]: any })
	local Character = Player.Character
	if not Character then
		return
	end

	self.Server:WeaponInput(Character, ActionName, Data)
end

function WeaponService:GetOverlapParams(Character)
	local op = OverlapParams.new()
	if Character:GetAttribute("Enemy") then
		local Characters = {}
		for _, plrs in (Players:GetPlayers()) do
			table.insert(Characters, plrs.Character)
		end

		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = Characters
	else
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { workspace:WaitForChild("Enemies") }
	end

	return op
end

function WeaponService.KnitInit()
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	PlayerService = Knit.GetService("PlayerService")
	InventoryService = Knit.GetService("InventoryService")
	AnimationService = Knit.GetService("AnimationService")

	for _, weapon in (script:GetChildren()) do
		if not weapon:IsA("ModuleScript") then
			continue
		end
		Weapons[weapon.Name] = require(weapon)
	end
end
function WeaponService.KnitStart()
	print(Weapons)
	for _, weapon in Weapons do
		if weapon.Start then
			weapon.Start(Weapons.Default)
		end
	end
end

return WeaponService
