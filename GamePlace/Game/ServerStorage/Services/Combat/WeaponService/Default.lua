local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService

local Validate = require(game.ReplicatedStorage.Validate)

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
		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.4
		local HitEffect = Tool:GetAttribute("HitEffect") or Tool:GetAttribute("Type")

		DebounceService:AddDebounce(Humanoid, "AttackCombo", SwingSpeed + 0.1)
		DebounceService:AddDebounce(Humanoid, "AttackDebounce", SwingSpeed)
		Humanoid:SetAttribute("LastAttackTick", tick())
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)

		AnimationService:StopM1Animation(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationsFolder.Hit[Counter])
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()

		task.delay(0.20, function()
			local Hitted = {}
			HitboxService:CreatePartHitbox(Character, Vector3.new(5, 5, 5), 10, function(Enemy)
				if Enemy == Character then
					return
				end
				if table.find(Hitted, Enemy) then
					return
				end
				table.insert(Hitted, Enemy)

				return DamageService:TryHit(Humanoid, Enemy.Humanoid, Damage, HitEffect)
			end)
		end)

		WeaponService:IncreaseComboCounter(Humanoid)

		task.delay(SwingSpeed, function()
			-- CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)
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
