local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CharacterService = Knit.CreateService({
	Name = "CharacterService",
})
local CharacterSharedFunctions = require(game.ReplicatedStorage.CharacterSharedFunctions)
local PlayerService
local ClothingService
local WeaponService
local PostureService

local PhysicsService = game:GetService("PhysicsService")

function CharacterService:CreatePlayerHealth(Player: Player)
	local Character = Player.Character
	local PlayerHealth = game.ReplicatedStorage.Models.PlayerHealth:Clone()
	PlayerHealth.Adornee = Character:WaitForChild("Head")
	PlayerHealth.Parent = Character
	PlayerHealth.PlayerToHideFrom = Player

	local Name = PlayerHealth:WaitForChild("Name"):WaitForChild("PlayerName")
	Name.Text = Character.Name

	local Health = PlayerHealth.Health.SizeFrame

	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.HealthChanged:Connect(function(health)
		local Scale = health / Humanoid.MaxHealth
		local Color = Color3.fromRGB(2, 255, 150):Lerp(Color3.new(1, 0, 0), 1 - Scale)
		local Tween = TweenService:Create(
			Health,
			TweenInfo.new(0.25, Enum.EasingStyle.Cubic),
			{ Size = UDim2.fromScale(Scale, 1), BackgroundColor3 = Color }
		)
		Tween:Play()
	end)
end

function CharacterService:BindAttackTick(Humanoid: Humanoid)
	task.spawn(function()
		while Humanoid:IsDescendantOf(workspace) do
			repeat
				task.wait(0.1)
			until Humanoid:GetAttribute("LastAttackTick") + 2.5 <= tick()
			Humanoid:SetAttribute("ComboCounter", 0)
			Humanoid:GetAttributeChangedSignal("LastAttackTick"):Wait()
		end
	end)
end

function CharacterService:LoadCharacter(Player: Player)
	if not Player:IsDescendantOf(game) then
		return
	end

	if Player.Character then
		Player.Character:Destroy()
	end

	Player:LoadCharacter()

	local Data = PlayerService:GetData(Player)
	local SlotData = PlayerService:GetSlot(Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")

	repeat
		if Character.Parent ~= nil then
			Character.Parent = game.Workspace.Characters
		end
		task.wait()
	until Character.Parent == game.Workspace.Characters

	CharacterService:ApplyHumanoidDefaultAttributes(Humanoid)

	local points = Data.Points or {}
	local Endurance = points.Endurance or 0

	Humanoid.MaxHealth = math.floor(math.sqrt(100 * (Endurance + 1)) * 10)
	Humanoid.Health = math.floor(math.sqrt(100 * (Endurance + 1)) * 10)

	CharacterService:BindAttackTick(Humanoid)

	CharacterService:CreatePlayerHealth(Player)
	ClothingService:LoadCharacter(Player, SlotData.Character)

	Character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			Humanoid:SetAttribute("WeaponEquipped", true)
			Humanoid:SetAttribute("ComboCounter", 0)
			Humanoid:SetAttribute("WeaponName", tool.Name)
			Humanoid:SetAttribute("WeaponType", tool:GetAttribute("Type"))
		end
	end)

	Character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			Humanoid:SetAttribute("WeaponEquipped", false)
			Humanoid:SetAttribute("WeaponName", nil)
			Humanoid:SetAttribute("WeaponType", nil)
		end
	end)

	PostureService:BindPostureRegeneration(Humanoid)
	Humanoid:SetAttribute("Loaded", true)

	return Character
end

function CharacterService:ApplyHumanoidDefaultAttributes(Humanoid: Humanoid)
	Humanoid:SetAttribute("WeaponEquipped", false)
	Humanoid:SetAttribute("ComboCounter", 0)
	Humanoid:SetAttribute("AttackDebounce", false)
	Humanoid:SetAttribute("BlockReleaseTick", 0)
	Humanoid:SetAttribute("LastAttackTick", 0)

	Humanoid:SetAttribute("DefaultJumpPower", 40)
	Humanoid:SetAttribute("DefaultWalkSpeed", 12)

	Humanoid:SetAttribute("MaxPosture", 100)
	Humanoid:SetAttribute("Posture", 0)
	Humanoid:SetAttribute("IsAPlayer", true)
end

function CharacterService:UpdateWalkSpeed(Humanoid: Humanoid, newWalkspeed: number?, overwrite: string)
	local newWalkspeed = newWalkspeed or 12 -- pega o walkspeed de walk
	CharacterSharedFunctions:ChangeWalkSpeed(Humanoid, newWalkspeed)
end

function CharacterService:UpdateJumpPower(Humanoid: Humanoid, newJumpPower: number?, overwrite: string)
	local newJumpPower = newJumpPower or 50 -- pega o jumppower
	CharacterSharedFunctions:ChangeJumpPower(Humanoid, newJumpPower)
end

function CharacterService:UpdateWalkSpeedAndJumpPower(Humanoid: Humanoid)
	CharacterService:UpdateWalkSpeed(Humanoid)
	CharacterService:UpdateJumpPower(Humanoid)
end

function CharacterService.KnitStart()
	PhysicsService:RegisterCollisionGroup("Debris")
	PhysicsService:CollisionGroupSetCollidable("Debris", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Debris", "Enemies", false)
	PhysicsService:CollisionGroupSetCollidable("Debris", "Swords", false)
	PhysicsService:CollisionGroupSetCollidable("Debris", "Weapon", false)
	PhysicsService:CollisionGroupSetCollidable("Debris", "Camera", false)
	PhysicsService:CollisionGroupSetCollidable("Debris", "NPC", false)

	PostureService = Knit.GetService("PostureService")
	WeaponService = Knit.GetService("WeaponService")
	PlayerService = Knit.GetService("PlayerService")
	ClothingService = Knit.GetService("ClothingService")
end

return CharacterService
