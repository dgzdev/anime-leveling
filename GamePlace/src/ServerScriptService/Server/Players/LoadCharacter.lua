local LoadCharacter = {}

export type CharacterData = {
	["FaceAccessory"]: number,
	["HairAccessory"]: number,
	["BackAccessory"]: number,
	["WaistAccessory"]: number,
	["ShouldersAccessory"]: number,
	["NeckAccessory"]: number,
	["HatAccessory"]: number,
	["Shirt"]: number,
	["Pants"]: number,
	["Colors"]: { number },
}
function LoadCharacter:FromData(player: Player, data: CharacterData)
	task.wait()
	local character = player.Character or player.CharacterAdded:Wait()

	local Head = character:FindFirstChild("Head")
	local Torso = character:FindFirstChild("Torso")
	local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local RightArm = character:FindFirstChild("Right Arm")
	local LeftArm = character:FindFirstChild("Left Arm")
	local RightLeg = character:FindFirstChild("Right Leg")
	local LeftLeg = character:FindFirstChild("Left Leg")

	HumanoidRootPart.Anchored = true

	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	local HumanoidDescription = Instance.new("HumanoidDescription")

	for name, value in pairs(data) do
		if name == "Colors" then
			local Color = Color3.fromRGB(value[1], value[2], value[3])
			HumanoidDescription.HeadColor = Color
			HumanoidDescription.LeftArmColor = Color
			HumanoidDescription.RightArmColor = Color
			HumanoidDescription.LeftLegColor = Color
			HumanoidDescription.RightLegColor = Color
			HumanoidDescription.TorsoColor = Color
		else
			HumanoidDescription[name] = value
		end
	end
	task.wait()
	humanoid:ApplyDescription(HumanoidDescription, Enum.AssetTypeVerification.Default)

	HumanoidRootPart.Anchored = false
end

return LoadCharacter
