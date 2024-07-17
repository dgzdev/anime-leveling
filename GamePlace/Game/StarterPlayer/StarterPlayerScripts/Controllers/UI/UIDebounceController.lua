local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local UIDebounceController = Knit.CreateController({
	Name = "UIDebounceController",
})

local DebounceService

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Debounces = PlayerGui:WaitForChild("Debounces")
local Content = Debounces:WaitForChild("content")

local Tweens = {}
local Connections = {}

function UIDebounceController:UpdateDebounces(DebounceData: { Duration: number, Name: string })
	local Name = DebounceData.Name
	local Duration = DebounceData.Duration

	local Placeholder
	local HaveDebounce = Content:FindFirstChild(Name)

	if HaveDebounce then
		Connections[Name]:Disconnect()
		Connections[Name] = nil
		Tweens[Name]:Cancel()

		HaveDebounce.Cooldown.Size = UDim2.new(1, 0, 1, 0)
		Placeholder = HaveDebounce
	else
		Placeholder = Debounces.Placeholder:Clone()
		Placeholder.SkillName.Text = "   " .. Name
		Placeholder.Visible = true
		Placeholder.Name = Name
		Placeholder.Parent = Content
		Tweens[Name] = TweenService:Create(
			Placeholder.Cooldown,
			TweenInfo.new(Duration, Enum.EasingStyle.Linear),
			{ Size = UDim2.new(0, 0, 1, 0) }
		)
	end

	Connections[Name] = Tweens[Name].Completed:Once(function()
		Placeholder:Destroy()
		Tweens[Name] = nil
		Connections[Name] = nil
	end)

	Tweens[Name]:Play()
end

function UIDebounceController:AddDebounce(Name: string, Duration: number)
	UIDebounceController:UpdateDebounces({ Name = Name, Duration = Duration })
end

function UIDebounceController.KnitStart()
	DebounceService = Knit.GetService("DebounceService")

	DebounceService.DebounceAdded:Connect(function(DebounceData)
		UIDebounceController:UpdateDebounces(DebounceData)
	end)
end

return UIDebounceController
