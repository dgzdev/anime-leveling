local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PostureService = Knit.CreateService({
	Name = "PostureService",
	Client = {},
})

local CombatService

function PostureService:AddPostureDamage(Humanoid: Humanoid, Amount: number, ByDeflect: boolean?)
	local ByDeflect = ByDeflect or false
	local DamageClap = math.clamp(Amount, 0, Humanoid:GetAttribute("MaxPosture") - Humanoid:GetAttribute("Posture"))
	Humanoid:SetAttribute("Posture", Humanoid:GetAttribute("Posture") + DamageClap)

	if not ByDeflect then
		if Humanoid:GetAttribute("Posture") >= Humanoid:GetAttribute("MaxPosture") and not Humanoid:GetAttribute("PostureBreak") then
			CombatService:PostureBreak(Humanoid)
		end
	end
end

function PostureService:RemovePostureDamage(Humanoid: Humanoid, Recover: number)
	local DamageClamp = math.clamp(Recover, 0, Humanoid:GetAttribute("Posture"))
	Humanoid:SetAttribute("Posture", Humanoid:GetAttribute("Posture") - DamageClamp)
end

function PostureService.KnitInit()
	CombatService = Knit.GetService("CombatService")
end

return PostureService
