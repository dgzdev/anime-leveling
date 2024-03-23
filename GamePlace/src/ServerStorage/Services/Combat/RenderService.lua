local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

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

	for _, player in players do
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:RenderForPlayersInArea(Position: Vector3, Area: number, RenderData: { string: any })
	for _, player in Players:GetPlayers() do
		if not player.Character or (player.Character:GetPivot().Position - Position).Magnitude > Area then
			continue
		end
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:RenderForPlayersExceptCaster(RenderData: { casterHumanoid: Humanoid })
	local casterPlayer = Players:GetPlayerFromCharacter(RenderData.casterHumanoid.Parent)
	local playersToRender = game.Players:GetPlayers()

	local index = table.find(playersToRender, casterPlayer)

	if index then
		table.remove(playersToRender, index)
	end

	RenderService:RenderForPlayers(RenderData, playersToRender)
end

function RenderService:CreateRenderData(casterHumanoid: Humanoid, module: string, effect: string, arguments: {}?)
	local RenderData = {
		casterHumanoid = casterHumanoid,
		module = module,
		effect = effect,
		arguments = arguments,
		casterRootCFrame = casterHumanoid.RootPart.CFrame,
	}

	return RenderData
end

return RenderService
