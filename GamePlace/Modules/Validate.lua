local Validate = {}

--[[
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Cooldowns = Validate.Cooldowns

    local endTick = Cooldowns(Humanoid: Humanoid, 1)
    print(endTick) -> 1634567890.123
    ```
]]

Validate.Cooldowns = setmetatable({
	__tasks = {},
}, {
	__call = function(self, Humanoid: Humanoid, number: number)
		assert(typeof(number) == "number", "[VALIDATE] Cooldown number must be a number")
		assert(typeof(Humanoid) == "Instance" and Humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")

		local toSet = tick() + number
		rawset(self, Humanoid, toSet)
		return toSet
	end,
})

--[[
    # GetCooldowns()
    > Validate.Cooldowns:GetCooldowns() -> table
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)

    local cooldowns = Validate.Cooldowns:GetCooldowns()
    print(cooldowns) -> { [Humanoid: Humanoid] = 1634567890.123 }
    ```
]]
function Validate.Cooldowns:GetCooldowns()
	return table.clone(Validate.Cooldowns)
end

--[[
    # DecreaseCooldown()
    > Validate.Cooldowns:DecreaseCooldown(name: string, number: number) -> number
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)

    local endTick = Validate.Cooldowns:DecreaseCooldown("Slash", 1)
    print(endTick) -> 1634567890.123
    ```
]]
function Validate.Cooldowns:DecreaseCooldown(humanoid: Humanoid, number: number): boolean | number
	assert(typeof(humanoid) == "Instance" and humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	assert(typeof(number) == "number", "[VALIDATE] Cooldown number must be a number")

	local currentCooldown = Validate.Cooldowns(humanoid)
	if not currentCooldown then
		return error("Cooldown not set for: " .. humanoid:GetFullName())
	end

	if tick() > currentCooldown then
		return true
	end
	if currentCooldown - number < tick() then
		return true
	end

	Validate.Cooldowns(humanoid, currentCooldown - number)

	return currentCooldown - number
end

--[[
    # IncreaseCooldown()
    > Validate.Cooldowns:IncreaseCooldown(humanoid: Humanoid, number: number) -> number
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)

    local endTick = Validate.Cooldowns:IncreaseCooldown(Humanoid, 1)
    print(endTick) -> 1634567890.123
    ```
]]
function Validate.Cooldowns:IncreaseCooldown(humanoid: Humanoid, number: number): number
	assert(typeof(humanoid) == "Instance" and humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	assert(typeof(number) == "number", "[VALIDATE] Cooldown number must be a number")

	local currentCooldown = Validate.Cooldowns(humanoid)
	if not currentCooldown then
		return error("Cooldown not set for: " .. humanoid:GetFullName())
	end

	Validate.Cooldowns(humanoid, currentCooldown + number)
	return currentCooldown + number
end

--[[
    # SetCooldown()
    > Validate.Cooldowns:SetCooldown(humanoid: Humanoid, time: number) -> number
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Humanoid: Humanoid = game.Players.LocalPlayer.Character.Humanoid

    local endTick = Validate.Cooldowns:SetCooldown(Humanoid, 1)
    print(endTick) -> 1634567890.123
    ```
]]
function Validate.Cooldowns:SetCooldown(humanoid: Humanoid, time: number): number
	assert(typeof(humanoid) == "Instance" and humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	assert(typeof(time) == "number", "[VALIDATE] Cooldown time must be a number")

	local endTick = Validate.Cooldowns(humanoid, time)
	return endTick
end

--[[
    # IsInCooldown()
    > Validate.Cooldowns:IsInCooldown(Humanoid: Humanoid) -> boolean
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Humanoid: Humanoid = game.Players.LocalPlayer.Character.Humanoid

    if Validate.Cooldowns:IsInCooldown(Humanoid) then
        print("Humanoid in COOLDOWN!")
    end
    ```
]]
function Validate.Cooldowns:IsInCooldown(Humanoid: Humanoid)
	assert(typeof(Humanoid) == "Instance" and Humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	return Validate.Cooldowns(Humanoid) > tick()
end

--[[
    # InAir()
    > Validate:InAir(Humanoid: Humanoid) -> boolean
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Humanoid: Humanoid = game.Players.LocalPlayer.Character.Humanoid

    if Validate:InAir(Humanoid) then
        print("Humanoid in AIR!")
    end
    ```
]]
function Validate:InAir(Humanoid: Humanoid): boolean
	assert(typeof(Humanoid) == "Instance" and Humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	return Humanoid:GetState() == Enum.HumanoidStateType.FallingDown
		or Humanoid:GetState() == Enum.HumanoidStateType.Freefall
end

--[[
    # InGround()
    > Validate:InGround(Humanoid: Humanoid) -> boolean
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Humanoid: Humanoid = game.Players.LocalPlayer.Character.Humanoid

    if Validate:InGround(Humanoid) then
        print("Humanoid in GROUND!")
    end
    ```
]]
function Validate:InGround(Humanoid: Humanoid): boolean
	assert(typeof(Humanoid) == "Instance" and Humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	return Humanoid:GetState() == Enum.HumanoidStateType.Running
		or Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics
		or Humanoid:GetState() == Enum.HumanoidStateType.Landed
end

--[[
    # CanAttack()
    > Validate:CanAttack(Humanoid: Humanoid) -> boolean
    ```lua
    local Validate = require(game.ServerScriptService.Modules.Validate)
    local Humanoid: Humanoid = game.Players.LocalPlayer.Character.Humanoid

    if Validate:CanAttack(Humanoid) then
        print("Humanoid can attack!")
    end
    ```
]]
function Validate:CanAttack(Humanoid: Humanoid): boolean
	assert(typeof(Humanoid) == "Instance" and Humanoid:IsA("Humanoid"), "[VALIDATE] Humanoid must be a Humanoid")
	local canAttack = true

	if Validate.Cooldowns:IsInCooldown(Humanoid) then
		canAttack = false
		return canAttack
	end

	if Humanoid:GetAttribute("Stun") then
		canAttack = false
		return canAttack
	end

	if Humanoid.RootPart.Anchored then
		canAttack = false
		return canAttack
	end

	return canAttack
end

return Validate
