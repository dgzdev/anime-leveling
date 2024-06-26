local Workspace = game:GetService("Workspace")
local Finder = {}
local Path

function Finder.IsOnDot(from: Humanoid, humanoid: Humanoid, debug): boolean
	if not humanoid:IsDescendantOf(workspace) then
		return false
	end

	local npcToCharacter = (humanoid.RootPart.Position - from.RootPart.Position).Unit :: Vector3
	local npcLook = from.RootPart.CFrame.LookVector

	local dotProduct = npcToCharacter:Dot(npcLook)

	if debug then
		local hasDot = tostring(dotProduct):find(".")
		local isNegative = dotProduct < 0

		local sub = 1
		if isNegative then
			sub += 1
		end
		if hasDot then
			sub += 2
		end

		local dot = tostring(dotProduct)
		if hasDot then
			dot = dot:sub(1, dot:find(".") + sub)
		end
	end

	if dotProduct > 0.5 then
		return dotProduct
	else
		return false
	end
end

function Finder.GetClosestHumanoid(from: Humanoid, onlyPlayers: boolean, magnitude: number): Humanoid?
	local closest: Humanoid = nil
	--if Path.InPath then
	--	return
	--end

	if onlyPlayers then
		for _, player in game.Players:GetPlayers() do
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				if closest then
					if not closest:IsDescendantOf(workspace) then
						closest = nil
					end
				end

				if not player.Character:IsDescendantOf(workspace) then
					continue
				end

				local hum = player.Character:FindFirstChild("Humanoid")
				if hum.Health <= 0 then
					continue
				end

				local RootPart = player.Character.Humanoid.RootPart
				if not RootPart then
					continue
				end
				local Position = RootPart.Position
				if not Position then
					continue
				end

				if not closest then
					local distance = (Position - from.RootPart.Position).Magnitude
					if distance < magnitude then
						closest = player.Character.Humanoid
					end
				else
					local distance1 = (closest.RootPart.Position - from.RootPart.Position).Magnitude
					local distance2 = (Position - from.RootPart.Position).Magnitude
					if distance2 < distance1 and distance2 < magnitude then
						closest = hum
					end
				end
			end
		end
	else

		for _, char: Humanoid in Workspace.Test:GetChildren() do
			if char:FindFirstChildWhichIsA("Humanoid") then
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum.Health <= 0 then
					continue
				end

				if not game.Players:GetPlayers()[hum.Parent.Name] then
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

function Finder.Start(path)
	Path = path
end

return Finder
