local knit = require(game.ReplicatedStorage.Packages.Knit)

local AI = script.AI
local Animations = script.Animations

Animations.Enabled = false

local EnemyService = knit.CreateService({
	Name = "EnemyService",
	Client = {},
})

local CachedInstances = {}

function EnemyService:CreateEnemy(enemy: Model)
	if CachedInstances[enemy] then
		return
	end

	CachedInstances[enemy] = true

	--> criar a ia dele
	local Actor = Instance.new("Actor", enemy)
	Actor.Name = "EnemyAI"

	local mainAI = AI:Clone()
	mainAI.Parent = Actor

	--> criar as animações dele
	local mainAnimations = Animations:Clone()
	mainAnimations.Parent = enemy

	--> ativar a ia dele
	task.wait()
	require(mainAI)

	--> ativar as animações dele
	mainAnimations.Enabled = true
end

function EnemyService.KnitStart()
	--> criar inimigos

	local Enemies = workspace.Test:GetChildren()
	for _, enemy in Enemies do
		if enemy:IsA("Model") then
			EnemyService:CreateEnemy(enemy)
		end
	end
end

return EnemyService
