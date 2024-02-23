local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local Sounds = {}

local SFXFolder = SoundService.Hit

function Sounds:GetRandomFrom(folder: Folder): Sound
	local sounds = folder:GetChildren()
	local sound = sounds[math.random(1, #sounds)]
	return sound
end

function Sounds:Apply(target: Model, action: string)
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

return Sounds
