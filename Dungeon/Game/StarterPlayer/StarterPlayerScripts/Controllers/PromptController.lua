local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local CameraController
local PortalService

local PromptController = Knit.CreateController({
	Name = "PromptController",
})

PromptController.ShopController = {}
PromptController.ShopController.debounce = false

PromptController.Prompts = {
	["EnterPortal"] = function(prompt: ProximityPrompt, player: Player)
		--> enter dungeon
		print("Entering dungeon!")
		PortalService:Teleport(player)
	end,
}

function PromptController.OnPrompt(prompt: ProximityPrompt, player: Player)
	local event: string = prompt:GetAttribute("Event")
	if PromptController.Prompts[event] then
		PromptController.Prompts[event](prompt, player)
	end
end

function PromptController:KnitInit()
	coroutine.wrap(function()
		local ProximityPromptService = game:GetService("ProximityPromptService")
		ProximityPromptService.PromptTriggered:Connect(PromptController.OnPrompt)
	end)()
	CameraController = Knit.GetController("CameraController")
	PortalService = Knit.GetService("PortalService")
end

return PromptController
