local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService

local Validate = require(game.ReplicatedStorage.Validate)
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local function getAllAnimationEventNames(animID: string): table
	local markers: table = {}
	local ks: KeyframeSequence = KeyframeSequenceProvider:GetKeyframeSequenceAsync(animID)
	local function recurse(parent: Instance)
		for _, child in pairs(parent:GetChildren()) do
			if (child:IsA("KeyframeMarker")) then
				table.insert(markers, child)
			end
			if (#child:GetChildren() > 0) then
				recurse(child)
			end
		end
	end
	recurse(ks)

	return markers
end

local Default = {
	Attack = function(Character, Data)
		local Humanoid = Character.Humanoid
		local Tool = HotbarService:GetEquippedTool(Character)

		if not Tool then
			return
		end
		if not Validate:CanAttack(Humanoid) then
			return
		end

		local Damage = Tool:GetAttribute("Damage") or 5
		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.3
		local HitEffect = Tool:GetAttribute("HitEffect") or Tool:GetAttribute("Type")

		DebounceService:AddDebounce(Humanoid, "AttackCombo", SwingSpeed + 0.15)
		DebounceService:AddDebounce(Humanoid, "AttackDebounce", SwingSpeed)
		Humanoid:SetAttribute("LastAttackTick", tick())
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)

		-- AnimationService:StopM1Animation(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")

		local AnimationPath: Animation = AnimationsFolder.Hit[Counter]
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()

		local Markers = getAllAnimationEventNames(AnimationPath.AnimationId)
		
		local function Attack()
			HitboxService:CreatePartHitbox(Character, Vector3.new(3, 3, 3), 10, function(Enemy)
				if Humanoid:GetAttribute("Hit") or Humanoid:GetAttribute("Blocked") or Humanoid:GetAttribute("Deflected") then
					return false
				end

				if Humanoid:GetAttribute("ComboCounter") > #AnimationsFolder:GetChildren() then
					
				end
				return DamageService:TryHit(Humanoid, Enemy.Humanoid, Damage, HitEffect)
			end)
		end

		if #Markers > 0 then
			Animation:GetMarkerReachedSignal("Hit"):Once(function()
				Attack()
			end)
		else
			task.delay(0.20, function()
				Attack()
			end)
		end

		WeaponService:IncreaseComboCounter(Humanoid)

		task.delay(SwingSpeed + 0.15, function()
			CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
		end)
	end,

	StrongAttack = function(Character, Data) end,
}

function Default.Start()
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	AnimationService = Knit.GetService("AnimationService")
end

return Default
