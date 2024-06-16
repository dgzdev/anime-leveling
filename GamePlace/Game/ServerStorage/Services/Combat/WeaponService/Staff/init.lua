local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService
local RagdollService

local Validate = require(game.ReplicatedStorage.Validate)
local FastCast = require(game.ReplicatedStorage.Modules.FastCastRedux)

local Default
Staff = {
	Attack = function(Character, Data)
        local Humanoid = Character.Humanoid
		local Tool = HotbarService:GetEquippedTool(Character)

		if not Tool then
			return
		end
		if not Validate:CanAttack(Humanoid) then
			return
		end

		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")

		local AnimationPath: Animation = AnimationsFolder.Hit[Counter]
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()

		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.3
		DebounceService:AddDebounce(Humanoid, "AttackCombo", SwingSpeed + 0.15)
		DebounceService:AddDebounce(Humanoid, "AttackDebounce", SwingSpeed)
		Humanoid:SetAttribute("LastAttackTick", tick())

		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local Damage = Tool:GetAttribute("Damage") or 5
		local HitEffect = Tool:GetAttribute("HitEffect") or Tool:GetAttribute("Type")
		local Markers = AnimationService:GetAllAnimationEventNames(AnimationPath.AnimationId)

	end,

	StrongAttack = function(...)
		Default.StrongAttack(...)
	end,
}

function Staff.Start(default)
	Default = default
    RagdollService = Knit.GetService("RagdollService")
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	AnimationService = Knit.GetService("AnimationService")
end

return Staff
