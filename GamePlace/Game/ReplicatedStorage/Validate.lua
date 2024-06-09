local Validate = {}

local function check(Humanoid: Humanoid, cant)
	for _, att in ipairs(cant) do
		if Humanoid:GetAttribute(att) == true then
			return false
		end
	end

	return true
end

function Validate:CanAttack(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"PostureBreak",
		"BlockEndLag",
		"Block",
		"Blocked",
		"AttackDebounce",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end

	return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
end

function Validate:CanBlock(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"BlockEndLag",
		"Roll",
		"Ragdoll",
		"PostureBreak",
		"Block",
		"AttackDebounce",
		"Downed",
		"BlockDebounce",
	}

	return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
end

return Validate
