local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Workspace = game:GetService("Workspace")

local PlayerEnter = Knit.CreateService({
	Name = "PlayerEnterService",
	Client = {},
})

PlayerEnter.OnPlayerAdded = function(player: Player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Root = Character:WaitForChild("HumanoidRootPart")
	task.wait()

	Root.Anchored = true
end

function PlayerEnter:CutsceneEnd(player: Player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Root = Character.PrimaryPart
	task.wait()

	Root.Anchored = false
end

function PlayerEnter:CutsceneStart(player)
	local Character = player.Character or player.CharacterAdded:Wait()
	local Root = Character.PrimaryPart
	task.wait(1)

	repeat
		Root.Anchored = true
		task.wait()
	until Root.Anchored == true or not player:IsDescendantOf(game.Players)

	Root.CFrame = Workspace:WaitForChild("CutscenePosition").CFrame
end

function PlayerEnter.Client:CutsceneEnd(player)
	self.Server:CutsceneEnd(player)
end

function PlayerEnter.Client:CutsceneStart(player)
	self.Server:CutsceneStart(player)
end

return PlayerEnter
