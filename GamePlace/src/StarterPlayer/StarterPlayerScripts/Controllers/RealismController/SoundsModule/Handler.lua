local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local SoundModule = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local MIN_DISTANCE = 0
local MAX_DISTANCE = 50

function SoundModule:Start()
	--[[
	Humanoid.Jumping:Connect(function(active)
		if active then
			local Sound = SoundService:WaitForChild("Character"):WaitForChild("Jump"):Clone()
			Sound.Parent = Root

			Sound.Name = "JUMP_FIX"

			Sound.RollOffMaxDistance = MAX_DISTANCE
			Sound.RollOffMinDistance = MIN_DISTANCE
			Sound.RollOffMode = Enum.RollOffMode.Linear

			local anim = TweenService:Create(Sound, TweenInfo.new(0.1), { Volume = Sound.Volume })
			Sound.Volume = 0

			anim:Play()

			Sound:Play()
			Debris:AddItem(Sound, Sound.TimeLength + 0.1)
		end
	end)
	]]
end

return SoundModule
