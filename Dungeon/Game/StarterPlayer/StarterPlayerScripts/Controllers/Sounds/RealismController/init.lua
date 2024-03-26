local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local FootstepsHandler = require(script.FootstepModule.Handler)
local SoundHandler = require(script.SoundsModule.Handler)

local Knit = require(ReplicatedStorage.Packages.Knit)

local Realism = Knit.CreateController({
	Name = "RealismController",
})

function Realism:SetMouseIcon(icon: number)
	UserInputService.MouseIcon = `rbxassetid://{icon}`
end

function Realism:KnitStart()
	Realism:SetMouseIcon(16856168951)

	SoundHandler:Start()
	FootstepsHandler:Start()
end

return Realism
