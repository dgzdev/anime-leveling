local CollectionService = game:GetService("CollectionService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local RenderController = Knit.CreateController({
	Name = "RenderController",
})

local RenderService
local Player = game.Players.LocalPlayer

--[[
    Executa a parte do client referente as particulas e skills, da emit nas particulas, cria as parts, move as parts, etc
]]

local RenderingModules = {}

function RenderController:CheckCache(module, casterHumanoid)
	if not module.Cache then
		module.Cache = {}
	end

	if not module.Cache[casterHumanoid] then
		module.Cache[casterHumanoid] = {
			Instances = {},
			Connections = {},
			Tasks = {},
			NamedTasks = {},
		}
	end
end
function RenderController:CreateInstance(module, casterHumanoid, newInstance)
	RenderController:CheckCache(module, casterHumanoid)

	table.insert(module.Cache[casterHumanoid].Instances, newInstance)
	return newInstance
end

function RenderController:GetInstance(module, casterHumanoid, name)
	RenderController:CheckCache(module, casterHumanoid)
	for i, v in ipairs(module.Cache[casterHumanoid].Instances) do
		if v.Name == name then
			return v, i
		end
	end
end
function RenderController:CreateConnection(module, casterHumanoid, connection)
	RenderController:CheckCache(module, casterHumanoid)

	table.insert(module.Cache[casterHumanoid].Connections, connection)
end

function RenderController:CreateTask(module, casterHumanoid, callback)
	RenderController:CheckCache(module, casterHumanoid)
	local index = #module.Cache[casterHumanoid].Tasks
	table.insert(module.Cache[casterHumanoid].Tasks, index, task.spawn(callback))
	return module.Cache[casterHumanoid].Tasks[index]
end

function RenderController:CreateNamedTask(module, casterHumanoid, name, callback)
	RenderController:CheckCache(module, casterHumanoid)

	module.Cache[casterHumanoid].NamedTasks[name] = task.spawn(callback)
	return module.Cache[casterHumanoid].NamedTasks[name]
end

function RenderController:ClearConnections(module, casterHumanoid)
	task.spawn(function()
		if module.Cache and module.Cache[casterHumanoid] then
			for i, v in ipairs(module.Cache[casterHumanoid].Connections) do
				v:Disconnect()
				module.Cache[casterHumanoid].Connections[i] = nil
			end
		end
	end)
end

function RenderController:ClearTasks(module, casterHumanoid)
	task.spawn(function()
		if module.Cache and module.Cache[casterHumanoid] then
			for i, v: thread in ipairs(module.Cache[casterHumanoid].Tasks) do
				task.cancel(v)
				module.Cache[casterHumanoid].Tasks[i] = nil
			end
		end
	end)
end

function RenderController:CancelNamedTask(module, casterHumanoid, name)
	if module.Cache and module.Cache[casterHumanoid] then
		if module.Cache[casterHumanoid].NamedTasks[name] then
			task.cancel(module.Cache[casterHumanoid].NamedTasks[name])
		end
	end
end

function RenderController:ClearNamedTasks(module, casterHumanoid)
	task.spawn(function()
		if module.Cache and module.Cache[casterHumanoid] then
			for i, v: thread in pairs(module.Cache[casterHumanoid].NamedTasks) do
				task.cancel(v)
				module.Cache[casterHumanoid].NamedTasks[i] = nil
			end
		end
	end)
end

function RenderController:ClearInstances(module, casterHumanoid)
	task.spawn(function()
		if module.Cache and module.Cache[casterHumanoid] then
			for i, v in ipairs(module.Cache[casterHumanoid].Instances) do
				v:Destroy()
				module.Cache[casterHumanoid].Instances[i] = nil
			end
		end
	end)
end

function RenderController:ClearCacheOfHumanoid(module: string, casterHumanoid: Humanoid)
	RenderController:ClearTasks(module, casterHumanoid)
	RenderController:ClearConnections(module, casterHumanoid)
	RenderController:ClearInstances(module, casterHumanoid)
end

function RenderController:StopPlayingMatchAnimation(Humanoid: Humanoid, AnimationName: string)
	local Animator = Humanoid:FindFirstChildWhichIsA("Animator")
	for i, v: AnimationTrack in ipairs(Animator:GetPlayingAnimationTracks()) do
		if v.Name:match(AnimationName) then
			v:Stop()
		end
	end
end

function RenderController:Emit(particle)
	particle:Emit(particle:GetAttribute("EmitCount") or 1)
end
function RenderController:EmitParticles(parent)
	for i, v in ipairs(parent:GetDescendants()) do
		if not v:IsA("ParticleEmitter") then
			continue
		end

		if v:GetAttribute("EmitDelay") then
			task.delay(v:GetAttribute("EmitDelay"), function()
				RenderController:Emit(v)
			end)
		else
			RenderController:Emit(v)
		end
	end
end
function RenderController.Render(RenderData)
	local ModuleToRender = RenderData.module

	if RenderingModules[ModuleToRender] then
		task.spawn(function()
			RenderingModules[ModuleToRender].Caller(RenderData)
		end)
	else
		print("Module not found!")
	end
end

function RenderController:ExecuteForCaster(RenderData, func)
	local Character = Player.Character
	local Humanoid = Character.Humanoid

	if RenderData.casterHumanoid == Humanoid then
		func()
	end
end

local function CreateRenderData(casterHumanoid: Humanoid, module: string, effect: string, arguments: {}?)
	local RenderData = {
		casterHumanoid = casterHumanoid,
		module = module,
		effect = effect,
		arguments = arguments,
		casterRootCFrame = casterHumanoid.RootPart.CFrame,
	}

	return RenderData
end

function RenderController.KnitStart()
	for i, v in ipairs(script:GetChildren()) do
		if v:IsA("ModuleScript") then
			RenderingModules[v.Name] = require(v)
		end
	end

	for i, v in pairs(RenderingModules) do
		if v.Start then
			v.Start()
		end
	end

	RenderService = Knit.GetService("RenderService")
	RenderService.Render:Connect(RenderController.Render)
end

return RenderController
