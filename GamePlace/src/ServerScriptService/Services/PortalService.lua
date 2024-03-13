local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PortalService = Knit.CreateService({
	Name = "PortalService",
	Client = {},
})

function PortalService:GeneratePortal()
	local portalTime = 60

	local success = false
	local TruePosition = Vector3.new()
	local Portal = game.ReplicatedStorage.Essentials.Portals.Portal:Clone()

	repeat
		local PortalMinY = -10
		local PortalMaxY = 30

		local Position = Vector3.new(math.random(-2048, 2048), 1000, math.random(-2048, 2048))
		local RealPosition = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)

		local Pos = RealPosition.CFrame.Position + Position

		local Rayparams = RaycastParams.new()
		Rayparams.FilterDescendantsInstances = { Workspace }
		Rayparams.IgnoreWater = true
		Rayparams.RespectCanCollide = true
		Rayparams.FilterType = Enum.RaycastFilterType.Include

		local Raycast = Workspace:Raycast(Pos, Vector3.new(0, -10000, 0), Rayparams)
		if Raycast then
			if Raycast.Position.Y > PortalMinY and Raycast.Position.Y < PortalMaxY then
				TruePosition = Raycast.Position

				Portal:ScaleTo(math.random(1, 1.2))

				Position = CFrame.new(TruePosition + Vector3.new(0, Portal:GetExtentsSize().Y / 2, 0))
					* CFrame.new(0, math.random(5, 10), 0)
					* CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

				Portal:PivotTo(Position)

				local ov = OverlapParams.new()
				ov.FilterDescendantsInstances = { Portal }
				ov.FilterType = Enum.RaycastFilterType.Exclude

				local parts = Workspace:GetPartBoundsInBox(Portal:GetPivot(), Portal:GetExtentsSize(), ov)
				if #parts == 0 then
					success = true

					local Ranks = {
						["D"] = 55,
						["C"] = 50,
						["B"] = 45,
						["A"] = 40,
						["S"] = 35,
					}

					local RankNumber = math.random(1, 100)

					local Rank = "E"

					for RankName, value in Ranks do
						if RankNumber <= value then
							Rank = RankName
							break
						end
					end

					print(Rank)

					local Prompt = Instance.new("ProximityPrompt", Portal)
					Prompt.ObjectText = `Rank: {Rank}`
					Prompt.HoldDuration = 2
					Prompt.ActionText = "Enter"
					Prompt.RequiresLineOfSight = false
					Prompt.MaxActivationDistance = 100
					Prompt:SetAttribute("Event", "EnterPortal")
					Prompt:SetAttribute("Rank", Rank)

					local rankTextLabel: TextLabel = Portal:FindFirstChild("Rank", true)
					if not rankTextLabel then
						warn("Rank text label not found in portal")
					end

					rankTextLabel.Text = Rank

					Portal.Parent = Workspace.Portals
				end
			end
		end
		task.wait()
	until success == true

	print("[PORTAL] Portal Position:", TruePosition)

	task.spawn(function()
		task.wait(portalTime)
		Portal:Destroy()
		self:GeneratePortal()
	end)
end
function PortalService:KnitInit()
	for i = 1, 5, 1 do
		task.delay(math.random(1, 120), function()
			self:GeneratePortal()
		end)
	end
end

return PortalService
