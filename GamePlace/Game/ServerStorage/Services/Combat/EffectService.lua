local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local EffectService = Knit.CreateService({
	Name = "EffectService",
	Client = {},
})

local HumanoidsWithEffects = {}

function EffectService:SumEffectValue(base: number, value: number, operation: string): number
    if operation == "int" then
        return value
    elseif operation == "%" then
        return (base * value) / 100
    elseif operation == "*" then
        return base * value
    end
end

function EffectService:HasEffect(Humanoid: Humanoid, EffectName: string)
	return HumanoidsWithEffects[Humanoid] and table.find(HumanoidsWithEffects[Humanoid], EffectName)
end

function EffectService:RemoveEffect(Humanoid: Humanoid, EffectName: string)
	if EffectService:HasEffect(Humanoid) then
		HumanoidsWithEffects[Humanoid][EffectName] = nil
	end
end

function EffectService:CheckHumanoid(Humanoid: Humanoid)
	if HumanoidsWithEffects[Humanoid] == nil then
		HumanoidsWithEffects[Humanoid] = {}

		Humanoid.Died:Once(function()
			HumanoidsWithEffects[Humanoid] = nil
		end)
	end
end

function EffectService:UpdateHumanoidEffects(Humanoid: Humanoid, EffectType: string)
	local EffectTypes = {
		Health = function()

		end,

		Burn = function()
			if #EffectService:GetEffectsByType(Humanoid, "Burn") == 0 then
				Humanoid:RemoveTag("Burn")
			else
				Humanoid:AddTag("Burn")
			end
		end,

		HealthRegeneration = function()

		end,

		Mana = function()

		end,

		ManaRegeneration = function()

		end,

		Damage = function()

		end,

		SpellDamage = function()

		end,

		Agility = function()

		end,

		Necromantic = function()

		end
	}

	if EffectTypes[EffectType] then
		EffectTypes[EffectType]()
	end
end


function EffectService:RemoveEffectsByType(Humanoid: Humanoid, EffectType: string)
	EffectService:CheckHumanoid(Humanoid)

	for _, effect: EffectDataType in HumanoidsWithEffects[Humanoid] do
		if effect.EffectType == EffectType then
			EffectService:RemoveEffect(Humanoid, effect.EffectName)
		end
	end

	EffectService:UpdateHumanoidEffects(Humanoid, EffectType)
end

function EffectService:GetEffectsByType(Humanoid: Humanoid, EffectType: string): {}
	EffectService:CheckHumanoid(Humanoid)

	local effects = {}
	for _, effect: EffectDataType in HumanoidsWithEffects[Humanoid] do
		if effect.EffectType == EffectType then
			table.insert(effects, effect)
		end
	end

	return effects
end

function EffectService:GetEffectTotalByType(Humanoid: Humanoid, EffectType: string, Base: number): number
	local Effects = EffectService:GetEffectsByType(Humanoid, EffectType)
	local Total = 0

	for _, effect: EffectDataType in pairs(Effects) do
	     Total += EffectService:SumEffectValue(Base, effect.Value, effect.ValueType)
	end

	return Total
end

function EffectService:AddEffect(
	Humanoid: Humanoid,
	EffectName: string,
	EffectType: string,
	Amount: number,
	ValueType: string,
	Duration: number?
)

	local Effect: EffectDataType = {
		EffectName = EffectName,
		EffectType = EffectType,
		Amount = Amount,
		ValueType = ValueType,
	}

	EffectService:CheckHumanoid(Humanoid)
	table.insert(HumanoidsWithEffects[Humanoid], Effect)

	EffectService:UpdateHumanoidEffects(Humanoid, EffectType)

	if Duration then
		task.delay(Duration, function()
			if HumanoidsWithEffects[Humanoid] then
				local index = table.find(HumanoidsWithEffects[Humanoid], Effect)
				table.remove(HumanoidsWithEffects[Humanoid], index)
				EffectService:UpdateHumanoidEffects(Humanoid, EffectType)
			end
		end)
	end
end

export type EffectDataType = {
	EffectName: string;
	EffectType: string;
	Amount: number;
	ValueType: string;
	Duration: number?;
}

return EffectService
