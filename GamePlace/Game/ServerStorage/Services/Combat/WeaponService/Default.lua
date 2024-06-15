local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeaponService
local HitboxService
local DamageService
local DebounceService
local CharacterService
local HotbarService
local AnimationService
local RagdollService

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
		local SwingSpeed = Tool:GetAttribute("SwingSpeed") or 0.3
		local HitEffect = Tool:GetAttribute("HitEffect") or Tool:GetAttribute("Type")


		local AnimationsFolder = AnimationService:GetWeaponAnimationFolder(Humanoid)

		-- AnimationService:StopM1Animation(Humanoid)
		local Counter = Humanoid:GetAttribute("ComboCounter")

		local AnimationPath: Animation = AnimationsFolder.Hit[Counter]
		local Animation: AnimationTrack = Humanoid.Animator:LoadAnimation(AnimationPath)
		Animation.Priority = Enum.AnimationPriority.Action
		Animation.Name = "M1_" .. tostring(Counter)
		Animation:Play()

		DebounceService:AddDebounce(Humanoid, "AttackCombo", SwingSpeed + 0.15)
		DebounceService:AddDebounce(Humanoid, "AttackDebounce", SwingSpeed)
		
		Humanoid:SetAttribute("LastAttackTick", tick())
		CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid)

		local Markers = AnimationService:GetAllAnimationEventNames(AnimationPath.AnimationId)

		local function Attack()
			DebounceService:AddDebounce(Humanoid, "HitboxStart", 0.05)
			HitboxService:CreatePartHitbox(Character, Vector3.new(6, 6, 6), 10, function(Enemy)
				if
					Humanoid:GetAttribute("Hit")
					or Humanoid:GetAttribute("Blocked")
					or Humanoid:GetAttribute("Deflected")
				then
					return false
				end				
				if
					DamageService:GetHitContext(Enemy.Humanoid) == "Hit"
					and Humanoid:GetAttribute("ComboCounter") - #AnimationsFolder:GetChildren() == -3 and not Enemy.Humanoid:GetAttribute("DeflectTime") and not Enemy.Humanoid:GetAttribute("Block")
				then
					RagdollService:Ragdoll(Enemy, 1)

					Enemy.PrimaryPart.AssemblyLinearVelocity = (
						Humanoid.RootPart.CFrame.LookVector
						* 200
						* WeaponService:GetModelMass(Enemy.Parent)
					)
				end
				
				WeaponService:TriggerHittedEvent(Enemy.Humanoid, Humanoid)
				return DamageService:TryHit(Enemy.Humanoid, Humanoid, Damage, HitEffect)
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
	RagdollService = Knit.GetService("RagdollService")
	WeaponService = Knit.GetService("WeaponService")
	HitboxService = Knit.GetService("HitboxService")
	DamageService = Knit.GetService("DamageService")
	DebounceService = Knit.GetService("DebounceService")
	CharacterService = Knit.GetService("CharacterService")
	HotbarService = Knit.GetService("HotbarService")
	AnimationService = Knit.GetService("AnimationService")
end

return Default
