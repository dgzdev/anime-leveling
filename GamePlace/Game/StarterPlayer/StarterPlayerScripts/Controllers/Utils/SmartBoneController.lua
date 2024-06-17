local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SmartBone = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("smartbone-2"))

local SmartBoneController = Knit.CreateController({
	Name = "SmartBoneController",
})

local Runtime: { Stop: () -> any }

function SmartBoneController.StartRuntime()
	assert(Runtime == nil, "[Smartbone] - Runtime already started")
	Runtime = SmartBone.Start()
end
function SmartBoneController.StopRuntime()
	assert(Runtime ~= nil, "[Smartbone] - Runtime not started")
	Runtime:Stop()
	Runtime = nil
end

function SmartBoneController.KnitInit()
	SmartBoneController.StartRuntime()
end

return SmartBoneController
