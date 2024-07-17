local Knit = require(game.ReplicatedStorage.Packages.Knit)
local TweenService = game:GetService("TweenService")
local TweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local AriseService = Knit.CreateService({
	Name = "AriseService",
})

local DebounceService

AriseService.Handler = {}

function AriseService:SetPossessionMode(TargetHumanoid, Player)
	if not AriseService[Player.Name] then
		AriseService[Player.Name] = {}
		table.insert(AriseService[Player.Name], TargetHumanoid)
		local Index = #AriseService[Player.Name]

		task.delay(10, function()
			table.remove(AriseService[Player.Name], Index)
			--local Char = TargetHumanoid.Parent
			--for i,v in pairs(Char:GetDescendants()) do
			--    if v:IsA("BasePart") then
			--        local Tween = TweenService:Create(v, TweenInfo, {Transparency = 1}) :: Tween
			--        Tween:Play()
			--        Tween.Completed:Once(function()
			--            v:Destroy()
			--        end)
			--    end
			--end
			--Char:Destroy()
		end)
	end
end

function AriseService:GetPossessionAvailable(Player)
	if AriseService[Player.Name] then
		return AriseService[Player.Name]
	end
end

function AriseService:RemovePossession(Player, Humanoid)
	if AriseService[Player.Name] then
		for i, v in pairs(AriseService[Player.Name]) do
			if v == Humanoid then
				table.remove(AriseService[Player.Name], i)
			end
		end
	end
end

function AriseService:KnitStart()
	DebounceService = Knit.GetService("DebounceService")
end

return AriseService
