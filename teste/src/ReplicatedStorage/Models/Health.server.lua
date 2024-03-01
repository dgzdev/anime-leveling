local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
-- Gradually regenerates the Humanoid's Health over time.

local REGEN_RATE = 2 / 100 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 30 -- Wait this long between each regeneration step.

--------------------------------------------------------------------------------

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Head = Character:WaitForChild("Head") :: BasePart
local LastHealth = Humanoid.MaxHealth

--------------------------------------------------------------------------------

local MIN_DISTANCE = 0
local MAX_DISTANCE = 30
local COOLDOWN = 0
local HEALCOOLDOWN = 0
local LAST_HEAL = tick()

local HealSound = SoundService:WaitForChild("SFX"):WaitForChild("Heal")

Humanoid.HealthChanged:Connect(function(health)
	if health > LastHealth then
		if LAST_HEAL + HEALCOOLDOWN > tick() then
			return
		end
		local heal = HealSound:Clone()
		heal.Parent = Head

		heal.RollOffMinDistance = MIN_DISTANCE
		heal.RollOffMaxDistance = MAX_DISTANCE
		heal.RollOffMode = Enum.RollOffMode.Linear

		heal:Play()
		Debris:AddItem(heal, heal.TimeLength + 0.2)
		LAST_HEAL = tick()
	end
	LastHealth = health
end)