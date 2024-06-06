local Knit = require(game.ReplicatedStorage.Packages.Knit)

local DamageService = Knit.CreateService {
    Name = "DamageService"
}

function DamageService:DealDamage(HumanoidToDamage: Humanoid, Damage: number, Humanoid: Humanoid?)
	if HumanoidToDamage.Health - 1 < 0 then return end
	local DamageClamp = math.clamp(Damage, 0, HumanoidToDamage.Health - 1)
	HumanoidToDamage:TakeDamage(DamageClamp)
end


return DamageService