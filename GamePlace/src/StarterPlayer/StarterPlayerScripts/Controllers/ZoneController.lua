local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local ZoneController = Knit.CreateController({
	Name = "ZoneController",
})

local ZonePlus = require(game.ReplicatedStorage.Modules.Zone)

local Player = game.Players.LocalPlayer
local ZoneGui = Player.PlayerGui:WaitForChild("Utils").Zones
local Background = ZoneGui.Background
local Title = Background.Title

function ZoneController.EnterPlace(ZoneName: string, Zone: BasePart)
	Title.Text = ZoneName

	if Zone:FindFirstChildWhichIsA("Sound") then
		Zone:FindFirstChildWhichIsA("Sound"):Play()
	end

	SoundService.Ambience.City:Stop()

	local anim =
		TweenService:Create(Background, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
			Position = UDim2.fromScale(0.5, 0.1),
		})
	anim:Play()

	anim.Completed:Wait()

	anim = TweenService:Create(
		Background,
		TweenInfo.new(0.95, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 4),
		{
			Position = UDim2.fromScale(0.5, -Background.Size.Y.Scale),
		}
	)
	anim:Play()
end

function ZoneController.LeavePlace(ZoneName: string, Zone: BasePart)
	if Zone:FindFirstChildWhichIsA("Sound") then
		Zone:FindFirstChildWhichIsA("Sound"):Stop()
	end

	SoundService.Ambience.City:Play()
end

local Zones = {}

function ZoneController:KnitStart()
	coroutine.wrap(function()
		local ZoneFolder = game.Workspace:FindFirstChild("Zones")

		for _, Zone: BasePart in ipairs(ZoneFolder:GetChildren()) do
			if Zones[Zone.Name] then
				continue
			end

			local ZoneManager = ZonePlus.new(Zone)
			Zones[Zone.Name] = ZoneManager

			ZoneManager.localPlayerEntered:Connect(function()
				self.EnterPlace(Zone.Name, Zone)
			end)

			ZoneManager.localPlayerExited:Connect(function()
				self.LeavePlace(Zone.Name, Zone)
			end)
		end

		ZoneFolder.ChildAdded:Connect(function(Zone: BasePart)
			if Zones[Zone.Name] then
				return
			end

			local ZoneManager = ZonePlus.new(Zone)
			Zones[Zone.Name] = ZoneManager

			ZoneManager.localPlayerEntered:Connect(function()
				self.EnterPlace(Zone.Name, Zone)
			end)

			ZoneManager.localPlayerExited:Connect(function()
				self.LeavePlace(Zone.Name, Zone)
			end)
		end)
	end)()
end

return ZoneController
