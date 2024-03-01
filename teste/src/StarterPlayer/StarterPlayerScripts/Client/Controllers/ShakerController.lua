local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CameraShaker = require(ReplicatedStorage.Modules.CameraShaker)

local ShakerController = Knit.CreateController({
	Name = "ShakerController",
})

ShakerController.Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	Workspace.CurrentCamera.CFrame *= shakeCFrame
end)

ShakerController.Presets = CameraShaker.Presets

function ShakerController:Shake(preset: any)
	self.Shaker:Shake(preset)
end

function ShakerController:KnitStart()
	self.Shaker:Start()
end

return ShakerController
