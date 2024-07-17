local Knit = require(game.ReplicatedStorage.Packages.Knit)

local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local PlayerGui = game.Players.LocalPlayer.PlayerGui

local CameraController

local MarketController = Knit.CreateController({
	Name = "MarketController",
})

MarketController.debounce = false
MarketController.CurrentCamera = 1
MarketController.Prompt = nil

local currentMarket = nil

function MarketController.TurnLeft()
	if not currentMarket then
		return
	end
	if MarketController.CurrentCamera - 1 <= 0 then
		return
	end
	if MarketController.debounce then
		return
	end

	MarketController.debounce = true
	local CameraFolder = currentMarket:WaitForChild("Cameras")
	local TweenI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Tween = TweenService:Create(
		Camera,
		TweenI,
		{ CFrame = CameraFolder[tostring(MarketController.CurrentCamera - 1)].CFrame }
	)
	Tween:Play()
	Tween.Completed:Connect(function(playbackState)
		Camera.CFrame = CameraFolder[tostring(MarketController.CurrentCamera - 1)].CFrame
		MarketController.CurrentCamera -= 1
		MarketController.debounce = false
	end)
	--> mostrar o produto da esquerda
end

function MarketController.TurnRight()
	--print(currentMarket)
	if not currentMarket then
		return
	end
	local CameraFolder = currentMarket:WaitForChild("Cameras")
	if MarketController.CurrentCamera + 1 > #CameraFolder:GetChildren() then
		return
	end
	if MarketController.debounce then
		return
	end

	MarketController.debounce = true
	local TweenI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Tween = TweenService:Create(
		Camera,
		TweenI,
		{ CFrame = CameraFolder[tostring(MarketController.CurrentCamera + 1)].CFrame }
	)
	Tween:Play()
	Tween.Completed:Connect(function(playbackState)
		Camera.CFrame = CameraFolder[tostring(MarketController.CurrentCamera + 1)].CFrame
		MarketController.CurrentCamera += 1
		MarketController.debounce = false
	end)
	--> mostrar o produto da direita
end

function MarketController.OnMarketClick(market: string, prompt)
	--> mostrar a gui
	MarketController.Prompt = prompt
	prompt.Enabled = false
	currentMarket = market
end

function MarketController.Hide()
	currentMarket = nil
	MarketController.Prompt.Enabled = true
	MarketController.Prompt = nil
	MarketController.debounce = false
	MarketController.CurrentCamera = 1
	PlayerGui:WaitForChild("PlayerHud").Enabled = true
	PlayerGui:WaitForChild("ShopUI").Enabled = false
	CameraController:EnableCamera()
	--> esconder a gui
end

function MarketController:KnitStart()
	CameraController = Knit.GetController("CameraController")
end

return MarketController
