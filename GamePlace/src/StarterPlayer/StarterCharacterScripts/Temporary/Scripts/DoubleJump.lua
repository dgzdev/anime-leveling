local DoubleJump = {}

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				mass += 0.1
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass
end

function DoubleJump:Init()
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()

	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")

	local jumpUsage = 1

	local uis = game:GetService("UserInputService")

	uis.InputBegan:Connect(function(key, gp)
		if (key.KeyCode == Enum.KeyCode.Space) or (key.KeyCode == Enum.KeyCode.ButtonA) and not gp then
			if humanoidRootPart and humanoid then
				if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					if jumpUsage >= 1 then
						jumpUsage -= 1

						local LookV = humanoid.MoveDirection * 25 * GetModelMass(char)
						humanoidRootPart.AssemblyLinearVelocity = LookV

						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						humanoid.StateChanged:Connect(function(old, new)
							if new == Enum.HumanoidStateType.Landed then
								jumpUsage = 1
							end
						end)
					end
				end
			end
		end
	end)
end

return DoubleJump
