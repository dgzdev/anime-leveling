local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()


if not game.Players:GetAttribute("Loaded") then
	game.Players:GetAttributeChangedSignal("Loaded"):Wait()
end

local last = tick()
local c
c = character.DescendantAdded:Connect(function(descendant: Instance) 
	last = tick()	
end)
while tick() - last < 1 do
	task.wait(1)
end
c:Disconnect()


local cam = Instance.new("Camera", script.Parent)
script.Parent.Parent.CurrentCamera = cam
cam.CFrame = CFrame.new(0,1.5,3)

character.Archivable = true
local new = character:Clone()
new.Parent = script.Parent
new:PivotTo(CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(180),0))

local newHumanoid = new:WaitForChild("Humanoid") :: Humanoid
local newAnimator = newHumanoid:WaitForChild("Animator") :: Animator


character.Archivable = false

local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

animator.AnimationPlayed:Connect(function(animationTrack: AnimationTrack) 
	for i, v in ipairs(newAnimator:GetPlayingAnimationTracks()) do
		if not v:IsA("Animation") then
			continue
		end
		v:Stop()
	end	
	
	if animationTrack:IsA("Animation") then
		newAnimator:LoadAnimation(animationTrack)
	end
end)