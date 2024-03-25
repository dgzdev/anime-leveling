local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Sounds = {}

local SFXFolder = SoundService.Hit

function Sounds:GetRandomFrom(folder: Folder): Sound
	local sounds = folder:GetChildren()
	local sound = sounds[math.random(1, #sounds)]
	return sound
end

function Sounds:_Apply(target: Model, action: string)
	if not target:IsDescendantOf(game.Workspace) then
		return
	end

	local Root
	if target:IsA("BasePart") then
		Root = target
	elseif target:IsA("Model") then
		Root = target.PrimaryPart
	end

	local newFolder = SFXFolder:FindFirstChild(action)
	if not newFolder then
		return error("SFX not found")
	end

	local sound = self:GetRandomFrom(newFolder):Clone()
	sound:SetAttribute("Ignore", true)

	sound.Parent = Root

	task.wait()

	sound:Play()

	Debris:AddItem(sound, sound.TimeLength)
end

function Sounds:_Create(target: Model, action: string, min: number?, max: number?, Loop: boolean?)
	if not target:IsDescendantOf(Workspace) then
		return
	end

	local Root
	if target:IsA("BasePart") then
		Root = target
	elseif target:IsA("Model") then
		Root = target.PrimaryPart
	end

	local SFX = SoundService:FindFirstChild(action, true)
	if not SFX then
		return error("SFX not found")
	end

	local sound: Sound | Folder = SFX:Clone()
	if sound:IsA("Folder") then
		sound = self:GetRandomFrom(sound):Clone()
	end

	sound:SetAttribute("Ignore", true)

	sound.RollOffMaxDistance = max or 60
	sound.RollOffMinDistance = min or 0
	sound.RollOffMode = Enum.RollOffMode.Linear

	sound.Parent = Root

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
