local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Source = game.ReplicatedStorage.Models.UI.DamageTemplate

local Indication = Knit.CreateController({
	Name = "Indication",
})

Indication.AllowedTags = {
	"Enemies",
	"Players",
	"Player",
	"Enemy",
}

function Indication.BindToAllNPCS()
	local Indicator: {
		Me: Humanoid,
		Start: () -> (),
		LastHealth: number,
		Connection: RBXScriptConnection,
	} =
		{}
	Indicator.__index = Indicator

	function Indicator.new(humanoid: Humanoid)
		local self = setmetatable({}, Indicator)

		self.Me = humanoid
		self.LastHealth = humanoid.Health

		return self
	end

	function Indicator:Start()
		local function propUI(damage: number)
			local dmg = tostring(damage)
			if dmg:find(".") then
				dmg = dmg:sub(1, dmg:find(".") + 3)
			end

			local isHeal = damage > 0
			local isDamage = damage < 0

			local clone: BillboardGui = Source:Clone()

			if isHeal then
				local OP = self.Me.MaxHealth / 100
				if damage < (OP * 10) then
					return
				end

				clone.Label.TextColor3 = Color3.new(0, 1, 0)
			elseif isDamage then
				clone.Label.TextColor3 = Color3.new(1, 0, 0)
			end

			clone.Parent = self.Me.RootPart

			clone.Label.Text = dmg
			local booble = (math.random(65, 110) / 100)
			clone.Size = UDim2.fromOffset(clone.Size.X.Offset * booble, clone.Size.Y.Offset * booble)

			clone.StudsOffset = Vector3.new(math.random(-10, 10) / 10, math.random(-10, 20) / 10, 0)

			local TweenProperties =
				TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0.25)

			local Tween = TweenService:Create(clone.Label, TweenProperties, {
				Position = UDim2.new(0.5, 0, 0.5, -50),
				TextTransparency = 1,
			})
			Tween.Completed:Once(function(playbackState)
				clone:Destroy()
			end)
			Tween:Play()
		end

		self.Connection = self.Me.HealthChanged:Connect(function(health)
			local dif = (self.LastHealth - health) * -1
			propUI(dif)

			self.LastHealth = health
		end)
	end

	function Indicator:Destroy()
		self.Connection:Disconnect()
	end

	local instances = {}

	for __index, tag: string in Indication.AllowedTags do
		local tagged = CollectionService:GetTagged(tag)
		for __index, enemy: Model in ipairs(tagged) do
			local humanoid = enemy:WaitForChild("Humanoid", 3)
			if humanoid then
				local indicator = Indicator.new(humanoid)
				instances[enemy] = indicator
				indicator:Start()
			end
		end
	end

	for _, tag: string in Indication.AllowedTags do
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(enemy: Model)
			local humanoid = enemy:WaitForChild("Humanoid", 3)
			if humanoid then
				local indicator = Indicator.new(humanoid)
				instances[enemy] = indicator
				indicator:Start()
			end
		end)
		CollectionService:GetInstanceRemovedSignal(tag):Connect(function(enemy: Model)
			local indicator = instances[enemy]
			if indicator then
				indicator:Destroy()
				instances[enemy] = nil
			end
		end)
	end
end

function Indication.KnitInit()
	Indication.BindToAllNPCS()
end

return Indication
