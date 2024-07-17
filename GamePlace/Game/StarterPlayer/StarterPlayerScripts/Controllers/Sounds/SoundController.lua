local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local SoundController = Knit.CreateController({
	Name = "SoundController",
})
local Current: Sound = nil
local Folder = game.SoundService.Theme

local function Shuffle(tbl)
	assert(type(tbl) == "table", "First argument must be a table")
	local rng = Random.new()
	for i = #tbl, 2, -1 do
		local j = rng:NextInteger(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

function SoundController:FadeIn(sound: Sound, time: number?)
	local volume = sound.Volume
	sound.Volume = 0
	sound:Play()
	TweenService:Create(sound, TweenInfo.new(time or 2.5), { Volume = volume }):Play()
end

function SoundController:FadeOut(sound: Sound, time: number?)
	local v = sound.Volume
	local a = TweenService:Create(sound, TweenInfo.new(time or 2.5), { Volume = 0 })
	a:Play()
	a.Completed:Wait()
	sound:Stop()
	sound.Volume = v
end

function SoundController:TransitionMusic(to: Sound, time: number?)
	if Current then
		SoundController:FadeOut(Current, time or 2.5)
	end
	Current = to
	SoundController:FadeIn(to, time or 2.5)
end

function SoundController:PlayMusic(sound: Sound)
	TweenService:Create(Folder, TweenInfo.new(0.75), {
		Volume = 0,
	}):Play()
	local volume = sound.Volume
	sound.Volume = 0
	sound:Play()
	TweenService:Create(sound, TweenInfo.new(0.75), {
		Volume = volume,
	}):Play()
	sound.Stopped:Once(function(soundId)
		TweenService:Create(Folder, TweenInfo.new(0.75), {
			Volume = 0.5,
		}):Play()
	end)
end

function SoundController:StartLoop()
	task.spawn(function()
		local Themes = SoundService.Theme
		while true do
			local sounds = Themes:GetChildren()
			sounds = Shuffle(sounds)

			for _, theme: Sound in sounds do
				if theme:IsA("Sound") then
					if Current then
						if Current.Playing then
							Current.Ended:Wait()
						end
					end

					SoundController:TransitionMusic(theme)

					if theme.TimeLength == 0 then
						theme.Loaded:Wait()
					end

					task.wait(theme.TimeLength - 2.5)
				end
			end
		end
	end)
end

function SoundController:KnitStart()
	self:StartLoop()
end

return SoundController
