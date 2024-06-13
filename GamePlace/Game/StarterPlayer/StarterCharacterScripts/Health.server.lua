local REGEN_RATE = 5 / 100 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 20 -- Wait this long between each regeneration step.

--------------------------------------------------------------------------------

if not script:IsDescendantOf(workspace) then
	script.AncestryChanged:Wait()
end

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

--------------------------------------------------------------------------------

while true do
	while Humanoid.Health < Humanoid.MaxHealth do
		task.wait(REGEN_STEP)
		local dh = (REGEN_RATE * Humanoid.MaxHealth)
		Humanoid.Health = math.min(Humanoid.Health + dh, Humanoid.MaxHealth)
	end
	Humanoid.HealthChanged:Wait()
end
