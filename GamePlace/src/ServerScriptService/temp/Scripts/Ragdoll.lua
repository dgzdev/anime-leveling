local RagdollHandler = {}

local Ragdoll: Ragdoll
function RagdollHandler:BindToAllNPCS()
	local function bind(hum: Humanoid)
		hum.BreakJointsOnDeath = false
		hum.Died:Once(function()
			local c = hum:FindFirstAncestorWhichIsA("Model")
			Ragdoll:Create(c)
		end)
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
end

function RagdollHandler:Init(Modules: { Ragdoll: ModuleScript })
	Ragdoll = require(Modules.Ragdoll)
	self:BindToAllNPCS()
end

export type Ragdoll = {
	Create: (target: Model) -> nil,
}
return RagdollHandler
