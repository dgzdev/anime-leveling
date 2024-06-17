local CharacterSharedFunctions = {}
function CharacterSharedFunctions:ChangeWalkSpeed(humanoid: Humanoid, amount: number?, overwrite: string?)
	local function change(toChange, walkspeed)
		if toChange == overwrite then
			humanoid.WalkSpeed = amount
		else
			humanoid.WalkSpeed = walkspeed
		end
	end

	local Walkspeeds = {
		Stun = function()
			change("Stun", 0)
		end,

		PostureBreak = function()
			change("PostureBreak", 0)
		end,

		Hit = function()
			change("Hit", 0)
		end,

		StrongAttack = function()
			change("StrongAttack", 0)
		end,

		AttackCombo = function()
			change("AttackCombo", 8)
		end,

		Block = function()
			change("Block", 4)
		end,

		Running = function()
			change("Running", 4)
		end,

		Crouch = function()
			change("Running", 6)
		end,

		Default = function()
			humanoid.WalkSpeed = 16
		end,
	}

	local set = false
	for attributeName, func in pairs(Walkspeeds) do
		if not humanoid:GetAttribute(attributeName) == true then
			continue
		end
		set = true
		func()
		break
	end

	if not set then
		Walkspeeds.Default()
	end
end

--[[
    Funciona da mesma forma que a função ChangeWalkspeed, porém alterando a propriedade de JumpPower do Humanoid
]]
function CharacterSharedFunctions:ChangeJumpPower(humanoid, amount, overwrite)
	amount = amount or humanoid:GetAttribute("DefaultJumpPower") or 40

	local function change(toChange, walkspeed)
		if toChange == overwrite then
			humanoid.JumpPower = amount
		else
			humanoid.JumpPower = walkspeed
		end
	end

	local JumpPowers = {
		Stun = function()
			change("Stun", 0)
		end,

		
		PostureBreak = function()
			change("PostureBreak", 0)
		end,

		Hit = function()
			change("Hit", 0)
		end,

		StrongAttack = function()
			change("StrongAttack", 0)
		end,

		AttackCombo = function()
			change("AttackCombo", 0)
		end,

		Default = function()
			humanoid.JumpPower = 40
		end,
	}

	local set = false
	for attributeName, func in pairs(JumpPowers) do
		if not humanoid:GetAttribute(attributeName) == true then
			continue
		end
		set = true
		func()
		break
	end

	if not set then
		JumpPowers.Default()
	end
end

return CharacterSharedFunctions
