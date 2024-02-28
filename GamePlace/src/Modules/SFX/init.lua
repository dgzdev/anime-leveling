local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local Sounds = {}

local SFXFolder = SoundService.Hit

function Sounds:GetRandomFrom(folder: Folder): Sound
	local sounds = folder:GetChildren()
	local sound = sounds[math.random(1, #sounds)]
	return sound
end

function Sounds:_Apply(target: Model, action: string)
	local newFolder = SFXFolder:FindFirstChild(action)
	if not newFolder then
		return error("SFX not found")
	end

	local sound = self:GetRandomFrom(newFolder):Clone()
	sound:SetAttribute("Ignore", true)

	sound.RollOffMaxDistance = 60
	sound.RollOffMinDistance = 0
	sound.RollOffMode = Enum.RollOffMode.Linear

	sound.Parent = target.PrimaryPart

	task.wait()

	sound:Play()

	Debris:AddItem(sound, sound.TimeLength)
end

function Sounds:_Create(target: Model, action: string, min: number?, max: number?, Loop: boolean?)
	local SFX = SoundService:FindFirstChild(action, true)
	if not SFX then
		return error("SFX not found")
	end

	local sound: Sound = SFX:Clone()
	sound:SetAttribute("Ignore", true)

	sound.RollOffMaxDistance = max or 60
	sound.RollOffMinDistance = min or 0
	sound.RollOffMode = Enum.RollOffMode.Linear

	local PrimaryPart
	if target:IsA("Model") then
		PrimaryPart = target.PrimaryPart
	elseif target:IsA("BasePart") then
		PrimaryPart = target
	else
		return error("Invalid target")
	end
	sound.Parent = PrimaryPart

	task.wait()

	sound:Play()

	if not Loop then
		Debris:AddItem(sound, sound.TimeLength)
	else
		sound.Looped = true
	end
end

function Sounds:Create(target: Model, action: string, min: number?, max: number?, Loop: boolean?)
	task.spawn(function()
		self:_Create(target, action, min, max, Loop)
	end)
end

function Sounds:Apply(target: Model, action: string)
	self:_Apply(target, action)
end

return Sounds
