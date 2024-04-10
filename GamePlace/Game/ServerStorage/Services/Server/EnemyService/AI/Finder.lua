local Workspace = game:GetService("Workspace")
local Finder = {}

function Finder.IsOnDot(from: Humanoid, humanoid: Humanoid): boolean
	local npcToCharacter = (humanoid.RootPart.Position - from.RootPart.Position).Unit :: Vector3
	local npcLook = from.RootPart.CFrame.LookVector

	local dotProduct = npcToCharacter:Dot(npcLook)

	if dotProduct > 0.5 then
		return true
	else
		return false
	end
end

function Finder.GetClosestHumanoid(from: Humanoid, onlyPlayers: boolean, magnitude: number): Humanoid?
	local closest: Humanoid = nil
	if onlyPlayers then
		for _, player in game.Players:GetPlayers() do
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				if not closest then
					local distance = (player.Character.Humanoid.RootPart.Position - from.RootPart.Position).Magnitude
					if distance < magnitude then
						closest = player.Character.Humanoid
					end
				else
					local distance1 = (closest.RootPart.Position - from.RootPart.Position).Magnitude
					local distance2 = (player.Character.Humanoid.RootPart.Position - from.RootPart.Position).Magnitude
					if distance2 < distance1 and distance2 < magnitude then
						closest = player.Character.Humanoid
					end
				end
			end
		end
	else
		for _, hum: Humanoid in Workspace:GetDescendants() do
			if hum:IsA("Humanoid") then
				if not game.Players:GetPlayerFromCharacter(hum.Parent) then
					if not closest then
						local distance = (hum.RootPart.Position - from.RootPart.Position).Magnitude
						if distance < magnitude then
							closest = hum
						end
					else
						local distance1 = (closest.RootPart.Position - from.RootPart.Position).Magnitude
						local distance2 = (hum.RootPart.Position - from.RootPart.Position).Magnitude
						if distance2 < distance1 and distance2 < magnitude then
							closest = hum
						end
					end
				end
			end
		end
	end

	return closest
end

return Finder
