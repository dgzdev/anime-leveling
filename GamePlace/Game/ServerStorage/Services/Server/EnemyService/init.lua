local knit = require(game.ReplicatedStorage.Packages.Knit)

local AI = script.AI
local Animations = script.Animations

Animations.Enabled = false
AI.Enabled = false

local EnemyService = knit.CreateService({
	Name = "EnemyService",
	Client = {},
})

function EnemyService:CreateEnemy(enemy: Model)
	--> criar a ia dele
	local Actor = Instance.new("Actor", enemy)
	Actor.Name = "EnemyAI"

	local mainAI = AI:Clone()
	mainAI.Parent = Actor

	--> criar as animações dele
	local mainAnimations = Animations:Clone()
	mainAnimations.Parent = enemy

	--> ativar a ia dele
	mainAI.Enabled = true

	--> ativar as animações dele
	mainAnimations.Enabled = true
end

function EnemyService.KnitInit()
	--> criar inimigos

	local Enemies = workspace.Test:GetChildren()
	for _, enemy in Enemies do
		EnemyService:CreateEnemy(enemy)
	end
end

return EnemyService
