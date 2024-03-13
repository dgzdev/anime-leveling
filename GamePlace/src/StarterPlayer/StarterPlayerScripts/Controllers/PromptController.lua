local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local CameraController
local MarketController

local PromptController = Knit.CreateController({
	Name = "PromptController",
})

PromptController.ShopController = {}
PromptController.ShopController.debounce = false

PromptController.Prompts = {
	["OpenShop"] = function(prompt: ProximityPrompt, player: Player)
		if PromptController.ShopController.debounce then
			return
		end
		PlayerGui:WaitForChild("PlayerHud").Enabled = false
		CameraController:DisableCamera()

		PromptController.ShopController.debounce = true
		Camera.CameraType = Enum.CameraType.Scriptable
		local Market = prompt.Parent.Parent
		MarketController.OnMarketClick(Market, prompt)
		local CameraFolder = Market:WaitForChild("Cameras")
		local TweenI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local Tween = TweenService:Create(Camera, TweenI, { CFrame = CameraFolder["1"].CFrame })
		Tween:Play()
		Tween.Completed:Connect(function(playbackState)
			Camera.CFrame = CameraFolder["1"].CFrame
			PromptController.ShopController.debounce = false
			PlayerGui:WaitForChild("ShopUI").Enabled = true
		end)
		--> open shop
		print("Opening shop!")
	end,
	["EnterDungeon"] = function(prompt: ProximityPrompt, player: Player)
		--> enter dungeon
		print("Entering dungeon!")
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
	MarketController = Knit.GetController("MarketController")
	CameraController = Knit.GetController("CameraController")
end

return PromptController
