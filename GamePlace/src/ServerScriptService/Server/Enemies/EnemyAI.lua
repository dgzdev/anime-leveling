local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	}, EnemyAI)

	self.Target.Name = "Target"
	self.Chasing.Name = "Chasing"

	self.Humanoid.WalkSpeed = self.Speed
	self.Humanoid.MaxHealth = self.Health
	self.Humanoid.Health = self.Health

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

			local Root = self.Target.Value:GetPivot().Position
			self.Humanoid:MoveTo(Root)
		until self.Humanoid.Health == 0
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

		until self.Humanoid.Health == 0
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
		until self.Humanoid.Health == 0
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
