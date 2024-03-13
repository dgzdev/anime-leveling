local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PortalService = Knit.CreateService({
	Name = "PortalService",
	Client = {},
})

local portal = {}
portal.__index = portal

function portal.new(Model: Model)
	local self = setmetatable({}, portal)

	self.Model = Model
	self.Enemies = {}

	local enemyTime = 25 -- 25 seconds = 12 enemies in 5 minutes

	local t = task.spawn(function()
		while true do
			self:GenerateEnemy("Goblin")

			task.wait(enemyTime)
		end
	end)

	self.Model.Destroying:Once(function()
		task.cancel(t)
	end)

	return self
end

function portal:ClearEnemies()
	for _, enemy in self.Enemies do
		enemy:Destroy()
	end

	self.Enemies = {}
end

function portal:GenerateEnemy(enemyName: string)
	local RIG = game.ReplicatedStorage.Essentials.RIG:Clone()
	RIG.Name = enemyName

	RIG.Parent = Workspace.Enemies

	local Root = RIG.PrimaryPart

	local Params = RaycastParams.new()
	Params.RespectCanCollide = true
	Params.FilterDescendantsInstances = { self.Model }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.IgnoreWater = true

	local pos = self.Model:GetPivot() * CFrame.new(math.random(-30, 30), 0, math.random(-30, 30))
	local Ray = Workspace:Raycast(pos.Position, Vector3.new(0, -1000, 0), Params)
	if Ray then
		RIG:PivotTo(
			CFrame.new(Ray.Position + Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)
		)
	end

	self.Enemies[#self.Enemies + 1] = RIG

	Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end

-- Check if there is any portal close
function PortalService:HasPortalClose(Position: Vector3, Radius: number)
	local Portals = Workspace.Portals:GetChildren()

	for _, p: Model in Portals do
		if (Position - p:GetPivot().Position).Magnitude <= Radius then
			return true
		end
	end

	return false
end

function PortalService:GeneratePortal()
	local portalTime = 300 -- 5 minutes

	local success = false
	local TruePosition = Vector3.new()
	local Portal = game.ReplicatedStorage.Essentials.Portals.Portal:Clone()

	local pt
	repeat
		local PortalMinY = -10
		local PortalMaxY = 30

		local Position = Vector3.new(math.random(-1024, 1024), 1000, math.random(-1024, 1024))
		local RealPosition = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)

		local Pos = RealPosition.CFrame.Position + Position

		-- Check if there is any portal close

		local Rayparams = RaycastParams.new()
		Rayparams.FilterDescendantsInstances = { Workspace }
		Rayparams.IgnoreWater = true
		Rayparams.RespectCanCollide = true
		Rayparams.FilterType = Enum.RaycastFilterType.Include

		local Raycast = Workspace:Raycast(Pos, Vector3.new(0, -10000, 0), Rayparams)
		if Raycast then
			if Raycast.Position.Y > PortalMinY and Raycast.Position.Y < PortalMaxY then
				TruePosition = Raycast.Position

				Position = CFrame.new(TruePosition + Vector3.new(0, Portal:GetExtentsSize().Y / 2, 0))
					* CFrame.new(0, math.random(5, 10), 0)
					* CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)

				-- Check if there is any portal close
				if self:HasPortalClose(Position.Position, 250) then
					continue
				end

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

					local Prompt = Instance.new("ProximityPrompt", Portal:FindFirstChild("PROMPT", true))
					Prompt.ObjectText = `Rank: {Rank}`
					Prompt.HoldDuration = 2
					Prompt.ActionText = "Enter"
					Prompt.RequiresLineOfSight = false
					Prompt.MaxActivationDistance = 50
					Prompt.Style = Enum.ProximityPromptStyle.Custom
					Prompt:SetAttribute("Event", "EnterPortal")
					Prompt:SetAttribute("Rank", Rank)

					local rankTextLabel: TextLabel = Portal:FindFirstChild("Rank", true)
					if not rankTextLabel then
						warn("Rank text label not found in portal")
					end

					rankTextLabel.Text = Rank

					Portal.Parent = Workspace.Portals

					pt = portal.new(Portal)

					local Scale = Portal:GetScale() * 100
					local NewScale = math.random(Scale / 2, Scale * 2)
					Portal:ScaleTo(math.abs(NewScale / 100))
				end
			end
		end
		task.wait()
	until success == true

	task.spawn(function()
		task.wait(portalTime)
		Portal:Destroy()
		self:GeneratePortal()
	end)
end
function PortalService:KnitInit()
	local keepPortals = 5
	for _i = 1, keepPortals, 1 do
		task.delay(math.random(1, 10), function()
			self:GeneratePortal()
		end)
	end
end

return PortalService
