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
	print("loading appearance")

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

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

	humanoid:ApplyDescription(HumanoidDescription)
end

return LoadCharacter
