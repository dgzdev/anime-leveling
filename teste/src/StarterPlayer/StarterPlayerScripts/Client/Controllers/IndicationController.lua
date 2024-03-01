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
		if not instance:IsA("Model") then
			continue
		end
		if not instance:FindFirstChild("Humanoid") then
			continue
		end
		if not instance:FindFirstChild("Head") then
			continue
		end

		DamageIndication.new(instance)
	end

	game.Workspace.DescendantAdded:Connect(function(descendant)
		if not descendant:IsA("Model") then
			return
		end
		if not descendant:FindFirstChild("Humanoid") then
			return
		end
		if not descendant:FindFirstChild("Head") then
			return
		end

		DamageIndication.new(descendant)
	end)
end

function Indication:KnitStart()
	ContentProvider:PreloadAsync({ Workspace })
	self:BindToAllNPCS()
end

return Indication
