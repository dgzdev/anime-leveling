local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Modules.Knit.Knit)

--[[
    Se comunica com o client para realizara renderização de efeitos
]]

local RenderService = Knit.CreateService({
	Name = "RenderService",
	Client = {
		Render = Knit.CreateSignal(),
	},
})

function RenderService:RenderForPlayers(RenderData: {}, players: { number: Player }?)
	local players = players or Players:GetPlayers()

	for _, player in ipairs(players) do
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:RenderForPlayersInArea(Position: Vector3, Area: number, RenderData: { string: any })
	for _, player in ipairs(Players:GetPlayers()) do
		if not player.Character or (player.Character:GetPivot().Position - Position).Magnitude > Area then
			continue
		end
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:CreateRenderData(casterHumanoid: Humanoid, module: string, effect: string, arguments: {}?)
	local RenderData = {
		casterHumanoid = casterHumanoid,
		module = module,
		effect = effect,
		arguments = arguments,
		casterRootCFrame = casterHumanoid.Parent.HumanoidRootPart.CFrame,
	}

	return RenderData
end

return RenderService
