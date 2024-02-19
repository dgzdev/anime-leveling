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
local COOLDOWN = 0.05
local HEALCOOLDOWN = 3
local LAST_TAKEN_DAMAGE = tick()
local LAST_HEAL = tick()

local HealSound = SoundService:WaitForChild("SFX"):WaitForChild("Heal")

Humanoid.HealthChanged:Connect(function(health)
	if LAST_TAKEN_DAMAGE + COOLDOWN > tick() then
		return
	end

	if health < LastHealth then
		local SFX = SoundService:WaitForChild("Hit"):GetChildren()
		local Sound = SFX[math.random(1, #SFX)]:Clone() :: Sound
		Sound.Parent = Head

		Sound.RollOffMinDistance = MIN_DISTANCE
		Sound.RollOffMaxDistance = MAX_DISTANCE
		Sound.RollOffMode = Enum.RollOffMode.Linear
		Sound.Volume = Sound.Volume * math.random(0.9, 1.1)

		Sound:Play()
		Debris:AddItem(Sound, Sound.TimeLength + 0.1)
		LAST_TAKEN_DAMAGE = tick()
	elseif health > LastHealth then
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

task.spawn(function()
	while true do
		while Humanoid.Health < Humanoid.MaxHealth do
			local dt = task.wait(REGEN_STEP)
			local dh = dt * REGEN_RATE * Humanoid.MaxHealth
			Humanoid.Health = math.min(Humanoid.Health + dh, Humanoid.MaxHealth)
		end
		Humanoid.HealthChanged:Wait()
	end
end)
