local Validate = {}

local function check(Humanoid: Humanoid, cant, debug)
	if Humanoid.RootPart == nil then
		return false
	end

	if Humanoid.RootPart.Anchored then
		return false
	end

	if Humanoid.Health <= 0 then
		return false
	end
	if Humanoid:GetAttribute("Ragdoll") then
		return false
	end

	for _, att in ipairs(cant) do
		if Humanoid:GetAttribute(att) == true then
			if debug then
				print(att)
			end
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
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"ComboDebounce",
		"Ragdoll",
		"JustSpawned"
	}

	return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
end

function Validate:CanUseSkill(Humanoid: Humanoid, NeedWeapon)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"PostureBreak",
		"UsingSkill",
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"Ragdoll",
		"JustSpawned"
	}
	if not NeedWeapon then
		return check(Humanoid, cant)
	else
		return check(Humanoid, cant) and Humanoid:GetAttribute("WeaponEquipped")
	end
end

function Validate:CanRoll(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"StrongAttack",
		"Hit",
		"PostureBreak",
		"Block",
		"UsingSkill",
		"Blocked",
		"AttackCombo",
		"AttackDebounce",
		"Deflected",
		"Ragdoll",
	}

	if Humanoid.WalkSpeed == 0 then
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
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"Ragdoll",
	}

	if Humanoid.WalkSpeed == 0 then
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
		"Block",
		"Blocked",
		"AttackCombo",
		"Deflected",
		"Ragdoll",
	}

	if Humanoid.WalkSpeed == 0 then
		return false
	end

	return check(Humanoid, cant)
end

function Validate:CanRun(Humanoid: Humanoid)
	local cant = {
		"Slide",
		"Roll",
		"Ragdoll",
		"UsingSkill",
		"PostureBreak",
		"Block",
		"AttackCombo",
		"Downed",
	}

	if Humanoid.WalkSpeed == 0 then
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
		"Unparryable",
	}

	return check(Humanoid, cant, false) and Humanoid:GetAttribute("WeaponEquipped")
end

return Validate
