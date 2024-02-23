local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Died = {}

local VFX = require(ReplicatedStorage.Modules.VFX)

local bound = {}

function Died:BindToAllNPCs()
	local function bind(hum: Humanoid)
		if bound[hum] then
			return
		end
		local c = hum.Died:Connect(function()
			VFX:ApplyParticle(hum.Parent, "Death Effect")
		end)
		bound[hum] = c
	end

	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Humanoid") then
			bind(obj)
		end
	end
	game.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Humanoid") then
			bind(descendant)
		end
	end)
	game.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("Humanoid") then
			if bound[descendant] then
				bound[descendant]:Disconnect()
				bound[descendant] = nil
			end
		end
	end)
end

function Died:Init()
	self:BindToAllNPCs()
end

return Died
