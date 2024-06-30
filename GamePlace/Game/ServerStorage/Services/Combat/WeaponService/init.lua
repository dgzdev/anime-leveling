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

function WeaponService:IsLastHit(Humanoid: Humanoid)
	local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)
	if not AnimationsFolder then
		return
	end
	return not (Humanoid:GetAttribute("ComboCounter") < #AnimationsFolder.Hit:GetChildren() - 1)
end

function WeaponService:IncreaseComboCounter(Humanoid: Humanoid)
	if not WeaponService:IsLastHit(Humanoid) then
		Humanoid:SetAttribute("ComboCounter", Humanoid:GetAttribute("ComboCounter") + 1)
	else
		DebounceService:AddDebounce(Humanoid, "ComboDebounce", 1.5)
		Humanoid:SetAttribute("ComboCounter", 0)
	end
end

function WeaponService:TriggerHittedEvent(EnemyHumanoid: Humanoid, HumanoidWhoHitted: Humanoid)
	local EnemyCharacter = EnemyHumanoid.Parent
	if EnemyCharacter:FindFirstChild("EnemyAI") then
		if EnemyCharacter:FindFirstChild("EnemyAI"):FindFirstChild("AI"):FindFirstChild("Hitted") then
			local HittedEvent =
			EnemyCharacter:FindFirstChild("EnemyAI"):FindFirstChild("AI"):FindFirstChild("Hitted") :: BindableEvent
			HittedEvent:Fire(HumanoidWhoHitted)
		end
	end
end

function WeaponService:Stun(Character: Model, Duration: number)
	DebounceService:AddDebounce(Character.Humanoid, "Stun", Duration)
	CharacterService:UpdateWalkSpeedAndJumpPower(Character.Humanoid)

	task.delay(Duration, function()
		CharacterService:UpdateWalkSpeedAndJumpPower(Character.Humanoid)
	end)
end

function WeaponService:StunLock(Character: Model, Position: Vector3, Duration: number)
	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Attachment0 = Character.PrimaryPart.RootAttachment
	AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	AlignPosition.MaxVelocity = math.huge
	AlignPosition.MaxForce = math.huge
	AlignPosition.Name = "StunAlignPosition"
	AlignPosition.Responsiveness = 100
	-- AlignPosition.RigidityEnabled = true
	AlignPosition.Position = Position
	AlignPosition.Parent = Character.PrimaryPart
	Debris:AddItem(AlignPosition, Duration)
end

function WeaponService:Block(Character: Model, state: boolean, cantParry: boolean?)
	if not Character then return end
	local Humanoid = Character.Humanoid
	if state then
		if not Validate:CanBlock(Humanoid) then
			-- Humanoid:SetAttribute("Block", false)
			return
		end

		local Animations = AnimationService:GetWeaponAnimationFolder(Humanoid)
		local BlockAnimation = Humanoid.Animator:LoadAnimation(Animations.Block)

		AnimationService:StopM1Animation(Humanoid)
		BlockAnimation:Play()

		DebounceService:AddDebounce(Humanoid, "BlockEndLag", 0.125)

		if not cantParry then --> se for true, não pode parry
			DebounceService:AddDebounce(Humanoid, "DeflectTime", 0.2, true)
		end
		Humanoid:SetAttribute("Block", true)
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
	else
		repeat
			task.wait()
		until not Humanoid:GetAttribute("BlockEndLag") and not Humanoid:GetAttribute("DeflectTime")
		DebounceService:AddDebounce(Humanoid, "BlockDebounce", 0.25)

		AnimationService:StopAnimationMatch(Humanoid, "Block")
		Humanoid:SetAttribute("BlockReleaseTick", tick())
		Humanoid:SetAttribute("Block", false)
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
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

	if Data and not Data.CasterCFrame then
		Data.CasterCFrame = Humanoid.Parent:GetPivot()
	end

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

function WeaponService:TypeBlockChecker(Humanoid: Humanoid, Data) -------------> Só pode ser usada para NPC's
	if not Data then
		return
	end

	if Humanoid:GetAttribute("BlockChecker") then
		return
	end

	DebounceService:AddDebounce(Humanoid, "BlockChecker", 0.3, true)

	local parryChance = Data.ParryChance / 100
	local blockChance = Data.BlockChance / 100
	local randomNumber = math.random(0, 100) / 100
	local isParry = randomNumber <= parryChance
	local isBlock = (randomNumber <= blockChance) and not isParry
	if isParry or Data.AUTO_PARRY then
		--print("Parry")
		if Data.AUTO_PARRY then
			Humanoid:SetAttribute("BlockDebounce", false)
			Humanoid:SetAttribute("Blocked", false)
			Humanoid:SetAttribute("BlockEndLag", false)
			Humanoid:SetAttribute("AttackCombo", false)
			Humanoid:SetAttribute("Block", false)
			Humanoid:SetAttribute("UsingSkill", false)
		end
		WeaponService:Block(Humanoid.Parent, true)
	elseif isBlock then
		--print("Block")
		WeaponService:Block(Humanoid.Parent, true, true)
	end
	task.delay(0.25, function()
		WeaponService:Block(Humanoid.Parent, false)
	end)
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

function WeaponService:GetModelMass(model: Model): number
	local mass = 1
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless == true then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass
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
