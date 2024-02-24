local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local PlayerManagers = require(script.Parent.Players)
local GameData = require(ServerStorage.GameData)
local RaycastHitbox = require(ReplicatedStorage.Modules.RaycastHitboxV4)

local HitService = require(script.HitService)

local CombatSystem = {}

local Combat = ReplicatedStorage.Events.Combat :: RemoteFunction

local VFX = require(ReplicatedStorage.Modules.VFX)
local SFX = require(ReplicatedStorage.Modules.SFX)

local PlayerCombos = {}

CombatSystem.Weapons = {
	["Sword"] = function(
		player: Player,
		props: { Damage: number, Humanoid: Humanoid, WeaponType: string, Attack: number, Attacks: number }
	)
		local Root = props.Humanoid.RootPart

		local Attack = props.Attack
		local Attacks = props.Attacks

		Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		Root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		--[[
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1, 1, 1) * math.huge

		local Direction
		if props.Humanoid.MoveDirection.Magnitude > 0 then
			Direction = props.Humanoid.MoveDirection.Unit
		else
			Direction = Root.CFrame.LookVector.Unit
		end

		bv.Velocity = Direction * 5
		bv.Parent = Root

		Debris:AddItem(bv, 0.5)
		]]

		local Damage = props.Damage
		local Character = props.Humanoid:FindFirstAncestorWhichIsA("Model")
		local Weapon = Character:FindFirstChild("Weapon")

		local Rayparams = RaycastParams.new()
		Rayparams.FilterType = Enum.RaycastFilterType.Blacklist
		Rayparams.FilterDescendantsInstances = { Character }
		Rayparams.IgnoreWater = true

		-- Attack logic
		local Hitbox = RaycastHitbox.new(Weapon)
		Hitbox.RaycastParams = Rayparams
		Hitbox.OnHit:Connect(function(hit, humanoid: Humanoid)
			if humanoid and (humanoid:IsDescendantOf(Workspace.Enemies)) then
				player:SetAttribute("Attacking", false)
				Hitbox:HitStop()

				if Attack == Attacks then
					HitService:Hit(props.Humanoid, humanoid, Damage, nil, Root.CFrame.LookVector * 10)
				else
					HitService:Hit(props.Humanoid, humanoid, Damage, nil, Root.CFrame.LookVector * 5)
				end

				local Char = humanoid:FindFirstAncestorWhichIsA("Model")
				VFX:ApplyParticle(Char, "SwordHit")
				SFX:Apply(Char, "SwordHit")

				if humanoid.Health <= 0 then
					CombatSystem:Kill(player, Char)
				end
			end
		end)
		task.delay(1, function()
			Character:SetAttribute("Attacking", false)
		end)
		Hitbox:HitStart(1)
	end,
	["Melee"] = function(
		player: Player,
		props: { Damage: number, Humanoid: Humanoid, WeaponType: string, Attack: number, Attacks: number }
	)
		local Attack = props.Attack
		local Attacks = props.Attacks

		local Root = props.Humanoid.RootPart

		Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		Root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		--[[
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1, 1, 1) * math.huge

		local Direction
		if props.Humanoid.MoveDirection.Magnitude > 0 then
			Direction = props.Humanoid.MoveDirection.Unit
		else
			Direction = Root.CFrame.LookVector.Unit
		end

		bv.Velocity = Direction * 5
		bv.Parent = Root

		Debris:AddItem(bv, 0.5)
		]]

		local Hitbox = Instance.new("Part")
		Hitbox.Size = Vector3.new(5, 5, 5)
		Hitbox.Anchored = false
		Hitbox.CanCollide = false
		Hitbox.Massless = true
		Hitbox.Transparency = 0.5
		Hitbox.Color = Color3.new(1, 0, 0)

		Hitbox.CFrame = Root.CFrame * CFrame.new(0, 0, -3)

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = Root
		Weld.Part1 = Hitbox
		Weld.Parent = Hitbox

		Hitbox.Parent = Workspace.Others

		local Params = OverlapParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = { Workspace.Enemies }
		Params.MaxParts = 1

		local ObjectsIn = Workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size, Params)
		local Hit = ObjectsIn[1]
		if Hit then
			local Model = Hit:FindFirstAncestorWhichIsA("Model")
			local Hum = Model:WaitForChild("Humanoid") :: Humanoid

			if Attack == Attacks then
				HitService:Hit(props.Humanoid, Hum, props.Damage, nil, Root.CFrame.LookVector * 10)
			else
				HitService:Hit(props.Humanoid, Hum, props.Damage, nil, Root.CFrame.LookVector * 5)
			end

			VFX:ApplyParticle(Model, "CombatHit")
			SFX:Apply(Model, "Melee")
		end

		task.delay(1, function()
			local Character = player.Character
			if not Character then
				return
			end
			Character:SetAttribute("Attacking", false)
		end)

		Debris:AddItem(Hitbox, 0.1)
	end,
}

CombatSystem.Attack = function(player: Player, props: { Attack: number, Attacks: number })
	local PlayerManager = PlayerManagers:GetPlayerManager(player)
	if not PlayerManager then
		return
	end

	local char = PlayerManager.Character

	if char:GetAttribute("Defending") then
		return
	end
	if char:GetAttribute("Stun") then
		return
	end

	local EquipedData = PlayerManager.Profile.Data.Equiped
	local Equiped = EquipedData.Weapon

	local InventoryData = GameData.gameWeapons[Equiped]
	local WeaponType = InventoryData.Type

	local Damage = InventoryData.Damage
	local Character = player.Character
	if not Character then
		return
	end

	local hum = Character:WaitForChild("Humanoid") :: Humanoid

	if hum.FloorMaterial == Enum.Material.Air then
		return
	end

	local WeaponAttack = CombatSystem.Weapons[WeaponType]
	if WeaponAttack then
		char:SetAttribute("Attacking", true)
		task.spawn(WeaponAttack, player, {
			Damage = Damage,
			Humanoid = hum,
			Equip_Data = EquipedData,
			WeaponType = WeaponType,
			Attack = props.Combo or 1,
			Attacks = props.Combos or 3,
		})
	else
		return error("Weapon type not found.")
	end

	return {
		Type = WeaponType,
	}
end

CombatSystem.Defend = function(player: Player, mode: "Start" | "End")
	local PlayerManager = PlayerManagers:GetPlayerManager(player)
	if not PlayerManager then
		return
	end

	local char = PlayerManager.Character

	if char:GetAttribute("Attacking") then
		return
	end
	if char:GetAttribute("Defending") and mode == "Start" then
		return
	end
	if not char:GetAttribute("Defending") and mode == "End" then
		return
	end
	if char:GetAttribute("Stun") then
		return
	end

	local EquipedData = PlayerManager.Profile.Data.Equiped
	local Equiped = EquipedData.Weapon

	local InventoryData = GameData.gameWeapons[Equiped]
	local WeaponType = InventoryData.Type

	local Character = player.Character
	if not Character then
		return
	end

	local hum = Character:WaitForChild("Humanoid") :: Humanoid

	if hum.FloorMaterial == Enum.Material.Air then
		return
	end

	if mode == "Start" then
		char:SetAttribute("Defending", true)
		char:SetAttribute("DefenseTick", tick())
	end

	if mode == "End" then
		char:SetAttribute("Defending", false)
	end

	return {
		Type = WeaponType,
	}
end

Combat.OnServerInvoke = function(player: Player, mode: string, ...)
	if CombatSystem[mode] then
		return CombatSystem[mode](player, ...)
	else
		return error("Mode not found.")
	end
end

function CombatSystem:Kill(player: Player, char: Model)
	local Enemy = char:GetAttribute("Name") or char.Name
	local EnemyAttributes = GameData.gameEnemies[Enemy]
	if not EnemyAttributes then
		return
	end

	local Gold, Experience = EnemyAttributes.Gold, EnemyAttributes.Experience

	local PlayerManager = PlayerManagers:GetPlayerManager(player)
	if not PlayerManager then
		return
	end

	PlayerManager:GiveGold(Gold)
	PlayerManager:GiveExperience(Experience)
end

function CombatSystem:Equip(player: Player)
	local PlayerManager = PlayerManagers:GetPlayerManager(player)
	local EquipedData = PlayerManager.Profile.Data.Equiped
	local Equiped = EquipedData.Weapon

	local InventoryData = GameData.gameWeapons[Equiped]
	local WeaponType = InventoryData.Type

	player:SetAttribute("WeaponType", WeaponType)
	player:SetAttribute("Equiped", Equiped)

	if WeaponType == "Sword" then
		local Model = ReplicatedStorage.Models.Swords
		local Sword = Model:FindFirstChild(Equiped)
		if not Sword then
			return error("Sword not found.")
		end

		local HaveWeaponEquiped = player.Character:FindFirstChild("Weapon")
		if HaveWeaponEquiped then
			HaveWeaponEquiped:Destroy()
		end

		local Character = player.Character or player.CharacterAdded:Wait()
		local Root = Character:WaitForChild("HumanoidRootPart")

		Root.Anchored = true

		local Position = "RightHand"

		local SwordClone = Sword:Clone() :: Model
		SwordClone.Name = "Weapon"
		SwordClone.Parent = Character

		local RightHand = Character:WaitForChild(Position)
		SwordClone:PivotTo(RightHand:GetPivot())

		local Motor6D = Instance.new("Motor6D")
		Motor6D.Part0 = RightHand
		Motor6D.Part1 = SwordClone.PrimaryPart
		Motor6D.C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), 0, 0))
		Motor6D.Parent = RightHand

		if not RunService:IsStudio() then
			PlayerManager.Profile:SetMetaTag("Equiped", Equiped)
		end

		Root.Anchored = false
	end

	if WeaponType == "Melee" then
		local Character = player.Character or player.CharacterAdded:Wait()
		local Weapon = Character:FindFirstChild("Weapon")
		if Weapon then
			Weapon:Destroy()
		end

		local MeleeFolder = ReplicatedStorage.Models.Melees
		local Melee = MeleeFolder:FindFirstChild(Equiped)
		if not Melee then
			return
		end
		if not Melee:IsA("Model") then
			return
		end

		local RightHand = Character:WaitForChild("Right Arm")
		local MeleeClone = Melee:Clone() :: Model
		MeleeClone.Name = "Weapon"
		MeleeClone.Parent = Character

		MeleeClone:PivotTo(
			RightHand:GetPivot() * CFrame.new(0, -1, -1.9) * CFrame.Angles(0, math.rad(180), math.rad(90))
		)

		local Weld = Instance.new("WeldConstraint")
		Weld.Parent = MeleeClone
		Weld.Part0 = RightHand
		Weld.Part1 = MeleeClone.PrimaryPart

		if not RunService:IsStudio() then
			PlayerManager.Profile:SetMetaTag("Equiped", Equiped)
		end
	end
end

return CombatSystem
