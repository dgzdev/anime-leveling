local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local RunService = game:GetService("RunService")

--[[
    Módulo responsável por fornecer hitboxes de forma mais prática
]]

local HitboxService = Knit.CreateService({
	Name = "HitboxService",
	Client = {},
})

local Enemies = game.Workspace:FindFirstChild("Enemies")

-- retorna todos os characters encontrados em uma table
function HitboxService:GetHumanoidsInTable(tabela)
	local Characters = {}

	for i, v in tabela do
		local Character = v.Parent
		if table.find(Characters, Character) then
			continue
		end
		if not Character:FindFirstChild("Humanoid") then
			continue
		end

		table.insert(Characters, Character)
	end

	return Characters
end

function HitboxService.Client:GetHumanoidsInTable(player, table)
	return self.Server:GetHumanoidsInTable(table)
end

function HitboxService:GetCharactersInBoxArea(cframe, size, Params)
	local Params = Params or OverlapParams.new()

	if not cframe then
		return print("CFrame is nil")
	end
	if not size then
		return print("Size is nil")
	end

	local Parts = game.Workspace:GetPartBoundsInBox(cframe, size, Params)

	local Characters = HitboxService:GetHumanoidsInTable(Parts)

	return Characters
end

function HitboxService:GetCharactersInPart(part: Part, Params: OverlapParams)
	local Params = Params or OverlapParams.new()
	local Parts = game.Workspace:GetPartsInPart(part, Params)
	local Characters = HitboxService:GetHumanoidsInTable(Parts)
	return Characters
end

function HitboxService.Client:GetCharactersInBoxArea(player, cframe, size, Params)
	return self.Server:GetCharactersInBoxArea(cframe, size, Params)
end

local function CheckCharacters(char1, char2)
	if char1 == char2 then
		return false
	end
	if char1.Name == char2.Name then
		return false
	end
	return true
end

function HitboxService:CreateStun(target: Model, time: number, callback: () -> nil)
	local Pr = target.PrimaryPart
	local Stun = Instance.new("LinearVelocity")
	Stun.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	Stun.MaxForce = math.huge

	Stun.VectorVelocity = Vector3.new(0, 0, 1)

	local Highlight = Instance.new("Highlight")
	Highlight.FillColor = Color3.new(1, 0, 0)
	Highlight.FillTransparency = 0.3
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	Highlight.OutlineColor = Color3.new(1, 1, 1)
	Highlight.OutlineTransparency = 0.1
	Highlight.Parent = target
	Debris:AddItem(Highlight, time)

	local att0 = Instance.new("Attachment", Pr)
	Stun.Attachment0 = att0

	Stun.Attachment0 = Pr:FindFirstChildWhichIsA("Attachment")
	target:SetAttribute("Stun", true)

	Stun.Parent = att0

	task.spawn(function()
		task.wait(time)
		att0:Destroy()
		target:SetAttribute("Stun", false)
		if callback then
			callback()
		end
	end)
end

function HitboxService:GetCharactersInCircleArea(position, radius, Params)
	local Params = Params or OverlapParams.new()

	if not position then
		return print("Position is nil")
	end
	if not radius then
		return print("Radius is nil")
	end

	local Parts = game.Workspace:GetPartBoundsInRadius(position, radius, Params)

	local Characters = HitboxService:GetHumanoidsInTable(Parts)

	return Characters
end
function HitboxService.Client:GetCharactersInCircleArea(player, position, radius, Params)
	return self.Server:GetCharactersInCircleArea(position, radius, Params)
end

function HitboxService:CreateHitboxFromModel(
	Character: Model,
	model: Model,
	scale: number?,
	CheckTicks: number,
	callback: any,
	Params: OverlapParams?
)
	local size = model:GetExtentsSize()
	scale = scale or 1

	local Hitted = {}

	if not Params then
		Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Workspace.Enemies, Workspace.Characters, Workspace.Test }
	end

	task.spawn(function()
		for i = 0, CheckTicks or 16, 1 do
			local Hitbox = HitboxService:GetCharactersInBoxArea(model:GetPivot(), size, Params)
			for i, char in Hitbox do
				if table.find(Hitted, char) then
					continue
				end
				if not CheckCharacters(char, Character) then
					continue
				end
				table.insert(Hitted, char)

				task.spawn(callback, char)
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

-- funciona da mesma forma que o CreatePartHitbox, porém sem criar uma part, apenas utilizando o GetPartBoundsInBox()
function HitboxService:CreateHitbox(
	Character: Model,
	HitboxSize: Vector3,
	CheckTicks: number,
	callback: (hitted: Model) -> nil,
	Params: OverlapParams?
)
	local Humanoid = Character:WaitForChild("Humanoid")

	local Hitted = {}
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local ComboCounterAtTime = Humanoid:GetAttribute("ComboCounter")

	if not Params then
		Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Enemies }
	end

	task.spawn(function()
		for i = 0, CheckTicks or 16, 1 do
			local Hitbox = HitboxService:GetCharactersInBoxArea(
				RootPart.CFrame * CFrame.new(0, 0, -(HitboxSize.Z / 2)),
				HitboxSize,
				Params
			)
			for i, char in Hitbox do
				if table.find(Hitted, char) then
					continue
				end
				if not CheckCharacters(char, Character) then
					continue
				end

				table.insert(Hitted, char)

				task.spawn(callback, char)
			end

			RunService.Heartbeat:Wait()
		end
	end)
end

function HitboxService:CreateFixedHitbox(CFrame: CFrame, Size: Vector3, Ticks: number, callback, Params: OverlapParams?, debug: boolean?)
	local Hitted = {}

	if not Params then
		Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Enemies, game.Workspace.Test, Workspace.Characters }
	end

	for i = 0, Ticks, 1 do
		local CharactersInside = HitboxService:GetCharactersInBoxArea(CFrame, Size, Params)

		for _, char in CharactersInside do
			if table.find(Hitted, char) then
				continue
			end
			table.insert(Hitted, char)
			task.spawn(callback, char)
		end

		if debug then
			local Part = Instance.new("Part")
			Part.Size = Size
			Part.Anchored = true
			Part.CFrame = CFrame
			Part.Parent = game.Workspace
			Part.Transparency = 0.5
			Part.Name = "DebugPart"
			Part.CanCollide = false
			Part.Color = Color3.fromRGB(255, 0, 0)

			Debris:AddItem(Part, 1)
		end

		RunService.Heartbeat:Wait()
	end
end

-- cria uma hitbox com part, welda, posiciona na frente do character fornecido com base no tamanho da hitbox, o callback retornara o character hitado
-- ticks é quantas vezes ele vai verificar a hitbox: 5 ticks = 5 vezes com o intervalo a cada frame
function HitboxService:CreatePartHitbox(
	Character: Model,
	HitboxSize: Vector3,
	Ticks: number,
	callback,
	params: OverlapParams?
)
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:WaitForChild("Humanoid")
	local Weld = Instance.new("WeldConstraint")
	local Hitbox = Instance.new("Part")
	Weld.Part0 = RootPart
	Weld.Part1 = Hitbox
	Weld.Parent = Hitbox
	Hitbox.Name = "Hitbox"
	Hitbox.Anchored = false
	Hitbox.CanCollide = false
	Hitbox.Massless = true
	Hitbox.Transparency = 1
	Hitbox.Size = HitboxSize
	Hitbox.CFrame = RootPart.CFrame * CFrame.new(0, 0, -HitboxSize.Z / 2)
	Hitbox.Parent = Character

	local Hitted = {}
	local Params = params
	if not Params then
		Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Enemies, Workspace.Test, Workspace.Characters }
	end

	for i = 0, Ticks, 1 do
		local CharactersInside = HitboxService:GetCharactersInPart(Hitbox, Params)
		for _, char in CharactersInside do
			if not CheckCharacters(char, Character) then
				continue
			end
			if table.find(Hitted, char) then
				continue
			end
			table.insert(Hitted, char)
			task.spawn(callback, char)
		end
		RunService.Heartbeat:Wait()
	end

	Hitbox:Destroy()
end

function HitboxService.KnitInit() end

return HitboxService
