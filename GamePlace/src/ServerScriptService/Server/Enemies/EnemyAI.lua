local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EnemyAI: AI = {}
EnemyAI.__index = EnemyAI

local View = require(script.Parent.View)

local Assets = {
	["Enemy"] = "16441552144",
}

function EnemyAI.new(Enemy: Model, Config: AIConfig)
	local self = setmetatable({
		Enemy = Enemy,
		Root = Enemy:WaitForChild("HumanoidRootPart"),
		Humanoid = Enemy:WaitForChild("Humanoid"),
		AILevel = Config.Inteligence or 5,

		Config = Config,
		Speed = Config.Speed,
		Health = Config.Health,
		Damage = Config.Damage,
		Name = Config.Name,
		HumanoidDescription = Config.HumanoidDescription,
		Died = Enemy:WaitForChild("Humanoid").Died,
	}, EnemyAI)

	local _Chasing = Enemy:FindFirstChild("Chasing", true)
	if _Chasing then
		_Chasing:Destroy()
	end

	local _Target = Enemy:FindFirstChild("Target", true)
	if _Target then
		_Target:Destroy()
	end

	local _Attacking = Enemy:FindFirstChild("Attacking", true)
	if _Attacking then
		_Attacking:Destroy()
	end

	self.Chasing = Instance.new("BoolValue", Enemy)
	self.Target = Instance.new("ObjectValue", Enemy)
	self.Attacking = Instance.new("BoolValue", Enemy)

	local _HealthHud = Enemy:FindFirstChild("HealthHud", true)
	if _HealthHud then
		_HealthHud:Destroy()
	end

	local _NPC_HUD = Enemy:FindFirstChild("NPC_Info", true)
	if _NPC_HUD then
		_NPC_HUD:Destroy()
	end

	local NPC_HUD = ReplicatedStorage:WaitForChild("Models"):WaitForChild("NPC_Info"):Clone()
	NPC_HUD.Parent = Enemy:WaitForChild("Head")
	NPC_HUD:WaitForChild("NPC_Name").Text = Enemy.Name
	NPC_HUD:WaitForChild("NPC_Image").Image = "rbxassetid://" .. Assets.Enemy

	local _HealthScript = Enemy:FindFirstChild("Health", true)
	if _HealthScript then
		_HealthScript:Destroy()
	end

	local HealthScript = ReplicatedStorage.Models.Health:Clone()
	HealthScript.Parent = Enemy

	self.Target.Name = "Target"
	self.Chasing.Name = "Chasing"

	self.Humanoid.WalkSpeed = self.Speed
	self.Humanoid.MaxHealth = self.Health
	self.Humanoid.Health = self.Health

	self.Attack = 1

	local MaxHealth = self.Humanoid.MaxHealth
	local HealthHud = ReplicatedStorage.Models.HealthHud:Clone()
	HealthHud.Parent = Enemy:WaitForChild("Head")

	self.AnimationPack = "Sword" or Config.AnimationPack

	if Config.HumanoidDescription then
		self.Humanoid:ApplyDescription(self.HumanoidDescription)
	end

	local bk = HealthHud:WaitForChild("Background")

	local PH = bk:WaitForChild("PrimaryHP")
	local SH = bk:WaitForChild("SecondaryHP")
	PH.Size = UDim2.fromScale(1, 1)
	SH.Size = UDim2.fromScale(1, 1)

	HealthHud.Enabled = false

	self.Humanoid.Died:Once(function()
		self.Target.Value = nil
		self.Attacking.Value = false
		self.Chasing.Value = false
	end)

	self.Humanoid.HealthChanged:Connect(function(health)
		if health < MaxHealth then
			HealthHud.Enabled = true
		end

		TweenService:Create(PH, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = UDim2.fromScale(health / MaxHealth, 1),
		}):Play()
		TweenService
			:Create(SH, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, false, 0.5), {
				Size = UDim2.fromScale(health / MaxHealth, 1),
			})
			:Play()

		task.delay(0.65, function()
			if health >= MaxHealth then
				HealthHud.Enabled = false
			end
		end)
	end)

	self.Enemy.Name = self.Name or "Untitled Entity"

	return self
end

function EnemyAI:BindChasing()
	task.spawn(function()
		repeat
			task.wait(0.6)
			if not self.Target.Value then
				continue
			end
			if self.Chasing.Value == false then
				continue
			end

			local Root = self.Target.Value:GetPivot().Position
			self.Humanoid:MoveTo(Vector3.new(Root.X, self.Root.Position.Y, Root.Z))

			if (self.Root.Position - self.Target.Value:GetPivot().Position).Magnitude < 5 then
				self.Attacking.Value = true
			else
				self.Attacking.Value = false
			end

		until self.Humanoid.Health <= 0
	end)
	task.spawn(function()
		repeat
			while self.Attacking.Value == true and self.Humanoid.Health > 0 do
				local target = self.Target.Value
				local Humanoid = target:FindFirstChildWhichIsA("Humanoid")

				self.Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				self.Humanoid.WalkSpeed = 0
				local Distance = (self.Root.Position - target:WaitForChild("HumanoidRootPart").Position).Magnitude

				if Humanoid and self.Humanoid.Health > 0 and Humanoid.Health > 0 and (Distance < 6) then
					local AnimationPack = self.AnimationPack :: string
					local Animations = ReplicatedStorage:WaitForChild("Animations")
						:WaitForChild(AnimationPack)
						:WaitForChild("Hit")
						:GetChildren()
					local Animation = Animations[self.Attack]

					local Animator = self.Humanoid:WaitForChild("Animator") :: Animator
					local AttackAnim = Animator:LoadAnimation(Animation)
					AttackAnim:Play()

					self.Attack = math.clamp(self.Attack + 1, 1, #Animations)

					Humanoid:TakeDamage(self.Config.Damage)

					if self.Attack == #Animations then
						self.Attack = 1
					end
				end

				task.wait(1)

				self.Humanoid.WalkSpeed = self.Speed
			end
			if self.Attacking.Value == false then
				self.Attacking.Changed:Wait()
			end

		until self.Humanoid.Health <= 0
	end)
end

function EnemyAI:Init()
	self:BindChasing()
	task.spawn(function()
		repeat
			local players = Players:GetPlayers()

			for _, player in ipairs(players) do
				local Character = player.Character or player.CharacterAdded:Wait()
				local Humanoid = Character:WaitForChild("Humanoid")

				if Humanoid.Health <= 0 then
					continue
				end

				local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
				local Distance = (HumanoidRootPart.Position - self.Root.Position).Magnitude
				if closest then
					if Distance < (closest.HumanoidRootPart.Position - self.Root.Position).Magnitude then
						closest = Character
					end
				else
					closest = Character
				end
			end

			self.Target.Value = closest
			task.wait(1)

		until self.Humanoid.Health <= 0
	end)

	task.spawn(function()
		local ViewFov = self.AILevel / 10
		local ViewDistance = self.AILevel * 1.5
		local MaxViewDistance = self.AILevel * 10

		repeat
			if self.Target.Value then
				local Target = self.Target.Value
				local TargetHead = Target:WaitForChild("Head")
				local TargetRoot = Target:WaitForChild("HumanoidRootPart")
				local Distance = View:GetDist(self.Root, TargetRoot)

				local InViewFov = View:IsInView(ViewFov, self.Root, TargetRoot)
				local InDistance = (Distance < MaxViewDistance)

				local Chase = false
				if InViewFov and InDistance and (View:ObjectInFront(self.Enemy:WaitForChild("Head"), TargetHead)) then
					Chase = true
				elseif
					(Distance < ViewDistance) and (View:ObjectInFront(self.Enemy:WaitForChild("Head"), TargetHead))
				then
					Chase = true
				else
					Chase = false
				end

				if Chase then
					self.Chasing.Value = true
				else
					self.Chasing.Value = false
				end
			end

			task.wait(1)
		until self.Humanoid.Health <= 0
	end)
end

export type AI = {
	Enemy: Model,
	Humanoid: Humanoid,
	Root: BasePart,

	Config: AIConfig,
	Speed: number,
	Health: number,
	Damage: number,
	Name: string | nil,

	Chasing: BoolValue,
	Target: ObjectValue,
	AILevel: number,

	LoadAIConfig: (config: AIConfig) -> nil,
	BindChasing: () -> nil,

	Init: () -> nil,
	new: () -> AI,
}
export type AIConfig = {
	Inteligence: number, --> (1 - 10)
	Speed: number,
	Health: number,
	Damage: number,
	Name: string | nil,
}
return EnemyAI
