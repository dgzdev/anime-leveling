local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatUtils = {}

function CombatUtils:Stun(target: Model, time: number)
	local hum = target:FindFirstChildWhichIsA("Humanoid")
	if not hum then
		return error("CombatUtils:Stun - Humanoid not found in target.")
	end

	local bfWalk = hum.WalkSpeed
	local bfJump = hum.JumpPower

	target:SetAttribute("Stun", true)

	hum.WalkSpeed = 0
	hum.JumpPower = 0

	task.wait(time)

	target:SetAttribute("Stun", false)

	hum.WalkSpeed = bfWalk
	hum.JumpPower = bfJump
end

return CombatUtils
