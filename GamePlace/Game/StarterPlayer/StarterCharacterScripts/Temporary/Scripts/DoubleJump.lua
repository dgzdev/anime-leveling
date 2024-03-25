local DoubleJump = {}
local Knit = require(game.ReplicatedStorage.Packages.Knit)

Knit.OnStart():await()

local StatusController = Knit.GetController("StatusController")

local SFX = require(game.ReplicatedStorage.Modules.SFX)

local function GetModelMass(model: Model)
	local mass = 0
	for _, part: BasePart in (model:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Massless then
				continue
			end
			mass += part:GetMass()
		end
	end
	return mass + 1
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
						local Stamina = StatusController:GetStamina()

						if Stamina - 10 < 0 then
							return
						end
						StatusController:WasteStamina(10)
						jumpUsage -= 1

						local LookV = humanoid.MoveDirection * 75 * GetModelMass(char)
						humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
						humanoidRootPart.AssemblyLinearVelocity = LookV + Vector3.new(0, 60, 0)

						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						SFX:Apply(char.HumanoidRootPart, "Jump")
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
