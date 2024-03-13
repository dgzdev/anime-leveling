local Knit = require(game.ReplicatedStorage.Packages.Knit)

local EffectService = Knit.CreateService({
	Name = "EffectService",
	Client = {},
})

local HumanoidsWithEffects = {}

function EffectService:HasEffect(Humanoid: Humanoid, EffectName: string)
	return HumanoidsWithEffects[Humanoid] and table.find(HumanoidsWithEffects[Humanoid], EffectName)
end

function EffectService:RemoveEffect(Humanoid: Humanoid, EffectName: string)
	if EffectService:HasEffect(Humanoid) then
		HumanoidsWithEffects[Humanoid][EffectName] = nil
	end
end

function EffectService:GetEffectByType(Humanoid: Humanoid, EffectType: string)
	if not HumanoidsWithEffects[Humanoid] then
		HumanoidsWithEffects[Humanoid] = {}
	end
end

function EffectService:AddEffect(
	Humanoid: Humanoid,
	EffectName: string,
	EffectType: string,
	Amount: number,
	ValueType: string
)
	local Effect = {
		EffectName = EffectName,
		EffectType = EffectType,
		Amount = Amount,
		ValueType = ValueType,
	}

	if not HumanoidsWithEffects[Humanoid] then
		HumanoidsWithEffects[Humanoid] = {}
	end

	table.find(HumanoidsWithEffects[Humanoid], Effect)
end

return EffectService
