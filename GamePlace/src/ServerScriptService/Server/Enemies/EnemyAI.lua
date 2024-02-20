local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EnemyAI: AI = {}
EnemyAI.__index = EnemyAI

local View = require(script.Parent.View)

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

		Chasing = Instance.new("BoolValue", Enemy),
		Target = Instance.new("ObjectValue", Enemy),
		Attacking = Instance.new("BoolValue", Enemy),
	}, EnemyAI)

	self.Target.Name = "Target"
	self.Chasing.Name = "Chasing"

	self.Humanoid.WalkSpeed = self.Speed
	self.Humanoid.MaxHealth = self.Health
	self.Humanoid.Health = self.Health

	local MaxHealth = self.Humanoid.MaxHealth
	local HealthHud = ReplicatedStorage.Models.HealthHud:Clone()
	HealthHud.Parent = Enemy:WaitForChild("Head")

	local bk = HealthHud:WaitForChild("Background")

	local PH = bk:WaitForChild("PrimaryHP")
	local SH = bk:WaitForChild("SecondaryHP")

	HealthHud.Enabled = false

	self.Humanoid.Died:Once(function()
		self.Target.Value = nil
		self.Attacking.Value = false
		self.Chasing.Value = false
		Enemy:Destroy()
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
			task.wait(0.3)
			if not self.Target.Value then
				continue
			end
			if self.Chasing.Value == false then
				continue
			end

			local Root = self.Target.Value:GetPivot().Position * 0.97
			self.Humanoid:MoveTo(Root)

			if (self.Root.Position - self.Target.Value:GetPivot().Position).Magnitude < 5 then
				self.Attacking.Value = true
			else
				self.Attacking.Value = false
			end

		until self.Humanoid.Health <= 0
	end)
	task.spawn(function()
		repeat
			while self.Attacking.Value == true do
				local target = self.Target.Value
				local Humanoid = target:FindFirstChildWhichIsA("Humanoid")

				self.Root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				self.Root.Anchored = true

				if Humanoid then
					Humanoid:TakeDamage(self.Config.Damage)
				end

				task.wait(1)

				self.Root.Anchored = false
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
			local closest = nil

			for _, player in ipairs(players) do
				local Character = player.Character or player.CharacterAdded:Wait()
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
			task.wait(0.5)

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

			task.wait(0.5)
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
