local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Indication = Knit.CreateController({
	Name = "Indication",
})

function Indication:BindToAllNPCS()
	local DamageIndication = require(ReplicatedStorage.Modules.DamageIndication)
	local Player = Players.LocalPlayer

	for _, instance in ipairs(game.Workspace:GetDescendants()) do
		if not instance:IsA("Humanoid") then
			continue
		end

		if not instance.Parent:FindFirstChild("Head") then
			continue
		end

		DamageIndication.new(instance.Parent)
	end

	game.Workspace.DescendantAdded:Connect(function(descendant)
		if not descendant:IsA("Humanoid") then
			return
		end

		DamageIndication.new(descendant.Parent)
	end)

	Workspace:FindFirstChild("Enemies").ChildAdded:Connect(function(enemy)
		DamageIndication.new(enemy)
	end)
end

function Indication:KnitStart()
	coroutine.wrap(function()
		self:BindToAllNPCS()
	end)()
end

return Indication
