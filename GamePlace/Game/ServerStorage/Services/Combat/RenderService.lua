local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

--[[
    Se comunica com o client para realizar a renderização de efeitos
]]

local RenderService = Knit.CreateService({
	Name = "RenderService",
	Client = {
		Render = Knit.CreateSignal(),
	},
})

export type RenderDataType = {
	casterHumanoid: Humanoid,
	module: string,
	effect: string,
	arguments: {any},
	casterRootCFrame: CFrame
}

function RenderService:RenderForPlayers(RenderData: RenderDataType, players: { number: Player }?)
	local players = players or Players:GetPlayers()

	for _, player in players do
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:RenderForPlayersInRadius(RenderData: RenderDataType, Position: Vector3, Area: number)
	for _, player in Players:GetPlayers() do
		if not player.Character or (player.Character:GetPivot().Position - Position).Magnitude > Area then
			continue
		end
		RenderService.Client.Render:Fire(player, RenderData)
	end
end

function RenderService:RenderForPlayersExceptCaster(RenderData: RenderDataType)
	local casterPlayer = Players:GetPlayerFromCharacter(RenderData.casterHumanoid.Parent)
	local playersToRender = game.Players:GetPlayers()

	local index = table.find(playersToRender, casterPlayer)

	if index then
		table.remove(playersToRender, index)
	end

	RenderService:RenderForPlayers(RenderData, playersToRender)
end

function RenderService:CreateRenderData(casterHumanoid: Humanoid, module: string, effect: string, arguments: {}?): RenderDataType
	local RenderData
	if casterHumanoid:IsA("Humanoid") then
		RenderData = {
			casterHumanoid = casterHumanoid,
			module = module,
			effect = effect,
			arguments = arguments,
			casterRootCFrame = casterHumanoid.Parent.HumanoidRootPart.CFrame,
		}
	else
		RenderData = {
			casterHumanoid = casterHumanoid,
			NotHumanoid = true,
			module = module,
			effect = effect,
			arguments = arguments,
		}
	end 
	return RenderData
end

return RenderService
