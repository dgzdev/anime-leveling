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
		"UsingSkill",
		"BlockEndLag",
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end
	if Humanoid.WalkSpeed == 0 then
		return false
	end
	if Humanoid.Health <= 0 then
		return false
	end

	return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
end
function Validate:CanRoll(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"PostureBreak",
		"BlockEndLag",
		"Block",
		"UsingSkill",
		"Blocked",
		"AttackCombo",
		"AttackDebounce",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end
	if Humanoid.WalkSpeed == 0 then
		return false
	end
	if Humanoid.Health <= 0 then
		return false
	end

	return check(Humanoid, cant)
end
function Validate:CanSlide(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"PostureBreak",
		"UsingSkill",
		"BlockEndLag",
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end
	if Humanoid.WalkSpeed == 0 then
		return false
	end
	if Humanoid.Health <= 0 then
		return false
	end
	if Humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		return false
	end

	return check(Humanoid, cant)
end
function Validate:CanDoubleJump(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"UsingSkill",
		"PostureBreak",
		"BlockEndLag",
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end
	if Humanoid.WalkSpeed == 0 then
		return false
	end
	if Humanoid.Health <= 0 then
		return false
	end

	return check(Humanoid, cant)
end

function Validate:CanBlock(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"BlockEndLag",
		"Roll",
		"Ragdoll",
		"UsingSkill",
		"PostureBreak",
		"Block",
		"AttackCombo",
		"Downed",
		"BlockDebounce",
	}

	if Humanoid.RootPart.Anchored then
		return false
	end
	if Humanoid.WalkSpeed == 0 then
		return false
	end
	if Humanoid.Health <= 0 then
		return false
	end

	return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
end

return Validate
