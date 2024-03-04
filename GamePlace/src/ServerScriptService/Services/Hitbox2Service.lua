local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

--[[
    Módulo responsável por fornecer hitboxes de forma mais prática
]]

local HitboxService = Knit.CreateService({
	Name = "Hitbox2Service",
	Client = {},
})

local Enemies = game.Workspace:FindFirstChild("Enemies")

-- retorna todos os characters encontrados em uma table
function HitboxService:GetHumanoidsInTable(tabela)
	local Characters = {}

	for i, v in ipairs(tabela) do
		local Character = v.Parent
		if table.find(Characters, Character) then
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
	callback: any
)
	local size = model:GetExtentsSize()
	scale = scale or 1

	size = size * scale

	local p0 = Instance.new("Part")
	p0.Size = size

	p0.Transparency = 0.8
	p0.CanCollide = false
	p0.Massless = true

	p0:PivotTo(model:GetBoundingBox())

	local w0 = Instance.new("WeldConstraint", p0)
	w0.Part0 = model.PrimaryPart
	w0.Part1 = p0

	p0.Parent = Character

	local Humanoid = Character:WaitForChild("Humanoid")

	local Hitted = {}
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local ComboCounterAtTime = Humanoid:GetAttribute("ComboCounter")

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = { Workspace.Enemies }

	task.spawn(function()
		for i = 0, CheckTicks or 16, 1 do
			local Hitbox = HitboxService:GetCharactersInBoxArea(p0.CFrame, size, Params)
			for i, char in pairs(Hitbox) do
				if char == Character then
					continue
				end
				if table.find(Hitted, char) then
					continue
				end
				table.insert(Hitted, char)

				local response = callback(char)
				if response == false then
					break
				end
			end

			task.wait()
		end

		p0:Destroy()
	end)
end

-- funciona da mesma forma que o CreatePartHitbox, porém sem criar uma part, apenas utilizando o GetPartBoundsInBox()
function HitboxService:CreateHitbox(
	Character: Model,
	HitboxSize: Vector3,
	CheckTicks: number,
	callback: (hitted: Model) -> nil
)
	local Humanoid = Character:WaitForChild("Humanoid")

	local Hitted = {}
	local RootPart = Character:WaitForChild("HumanoidRootPart")
	local ComboCounterAtTime = Humanoid:GetAttribute("ComboCounter")

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = { Enemies }

	task.spawn(function()
		for i = 0, CheckTicks or 16, 1 do
			local Hitbox = HitboxService:GetCharactersInBoxArea(
				RootPart.CFrame * CFrame.new(0, 0, -(HitboxSize.Z / 2)),
				HitboxSize,
				Params
			)

			for i, char in ipairs(Hitbox) do
				if char == Character then
					continue
				end
				if table.find(Hitted, char) then
					continue
				end
				table.insert(Hitted, char)

				local response = callback(char)
				if response == false then
					break
				end
			end

			task.wait()
		end
	end)
end

function HitboxService:CreateFixedHitbox(Position: CFrame, Size: Vector3, Ticks: number, callback)
	local Hitted = {}
	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Include
	Params.FilterDescendantsInstances = { Enemies }

	for i = 0, Ticks, 1 do
		local CharactersInside = HitboxService:GetCharactersInBoxArea(Position, Size, Params)

		for _, char in ipairs(CharactersInside) do
			if table.find(Hitted, char) then
				continue
			end
			table.insert(Hitted, char)
			local response = callback(char)
			if response == false then
				break
			end
		end
		task.wait()
	end
end

-- cria uma hitbox com part, welda, posiciona na frente do character fornecido com base no tamanho da hitbox, o callback retornara o character hitado
--ticks é quantas vezes ele vai verificar a hitbox: 5 ticks = 5 vezes com o intervalo a cada frame
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
		Params.FilterDescendantsInstances = { Enemies }
	end

	for i = 0, Ticks, 1 do
		local CharactersInside = HitboxService:GetCharactersInPart(Hitbox, Params)

		for _, char in ipairs(CharactersInside) do
			if char == Character then
				continue
			end
			if table.find(Hitted, char) then
				continue
			end
			table.insert(Hitted, char)
			local response = callback(char)
			if response == false then
				break
			end
		end
		task.wait()
	end

	Hitbox:Destroy()
end

function HitboxService.KnitInit() end

return HitboxService
