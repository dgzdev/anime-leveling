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

		Humanoid.Died:Connect(function()
			HumanoidsWithEffects[Humanoid] = nil
		end)

		Humanoid.Destroying:Connect(function()
			HumanoidsWithEffects[Humanoid] = nil
		end)
	end
end

function EffectService:UpdateHumanoidEffects(Humanoid: Humanoid, EffectType: string)
	local EffectTypes = {
		Health = function() end,

		HealthRegeneration = function() end,

		Mana = function() end,

		ManaRegeneration = function() end,

		Damage = function() end,

		SpellDamage = function() end,

		Agility = function() end,
	}

	if EffectTypes[EffectType] then
		EffectTypes[EffectType]()
	end
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
			local index = table.find(HumanoidsWithEffects, Effect)
			table.remove(HumanoidsWithEffects, index)
			EffectService:UpdateHumanoidEffects(Humanoid, EffectType)
		end)
	end
end

export type EffectDataType = {
	EffectName: string,
	EffectType: string,
	Amount: number,
	ValueType: string,
	Duration: number?,
}

return EffectService
