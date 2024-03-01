Config = {
	["Debug"] = false, --Print debug messages
	["PlayToolEquippedAnimation"] = true, --Put right hand up if tool is equipped
	["AllowEmotes"] = true, --Whether emotes can be used (e.g. "/e dance")
	["TimeInBetweenIdleAnimationChange"] = 10, --How much time before IdleAnim is changed to IdleAnim2
	["ChattedEvent"] = false, --If false, the module will listen to Player.Chatted for emotes. Otherwise, it will listen to this event.
}

--[[
	Made by a3nim
	Version 1.12
]]


return function(Rig, CustomConfig)
	local function Player()
		return game:GetService("Players").LocalPlayer
	end
	local function Humanoid()
		return Rig:WaitForChild("Humanoid")
	end
	
	if CustomConfig then
		for i, v in pairs(CustomConfig) do
			if Config[i] ~= nil then
				Config[i] = v
			end
		end
	end
	
	local Animations = {}
	local PreloadAnimation = require(script:WaitForChild("PreloadAnimation"))
	local AnimationsConfigFolder
	if Humanoid().RigType == Enum.HumanoidRigType.R15 then
		AnimationsConfigFolder = script:WaitForChild("Animations")
	else
		AnimationsConfigFolder = script:WaitForChild("Animations R6")
	end

	local function NewAnimation(Name, ID, Priority, IsEmote, Looped)
		Animations[Name] = {ID, nil, Priority, IsEmote, Looped}
		PreloadAnimation(ID)
	end

	local function GetAnimationId(AnimationName)
		return AnimationsConfigFolder:WaitForChild(AnimationName).Value
	end
	local function GetAnimationSpeed(AnimationName)
		--Some animations don't have their own config value like tool equip and emotes, return 1 for these
		if AnimationsConfigFolder:FindFirstChild(AnimationName) then
			return AnimationsConfigFolder:WaitForChild(AnimationName):GetAttribute("Speed")
		end
		return 1
	end

	local function PlayAnim(ID, Looped)
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(ID)
		local anim_track = Humanoid():LoadAnimation(anim)
		anim_track.Name = "LocalAnimation" --So you can differentiate local animations and animations which have been replicated.
		if Looped ~= nil then
			anim_track.Looped = Looped
		end
		anim_track:Play()

		return anim_track
	end

	local function RunAnimation(active, Anim)
		--[[
			[1] = ID,
			[2] = Track,
			[3] = Priority,
			[4] = Is Emote,
			[5] = Is Looped
		]]
		if active then
			if not Animations[Anim][2] then
				Animations[Anim][2] = PlayAnim(Animations[Anim][1], Animations[Anim][5])
				Animations[Anim][2].Priority = Animations[Anim][3]
				--print("Play:", Anim)
			end
		else
			if Animations[Anim][2] then
				--print("Stop:", Anim)
				Animations[Anim][2]:Stop(0.2)
				Animations[Anim][2] = nil
			end
		end
		
		if Animations[Anim][2] then
			Animations[Anim][2]:AdjustSpeed(GetAnimationSpeed(Anim))
		end
	end

	NewAnimation("IdleAnim", GetAnimationId("IdleAnim"), Enum.AnimationPriority.Core, false, true)
	NewAnimation("IdleAnim2", GetAnimationId("IdleAnim2"), Enum.AnimationPriority.Core, false, true)
	NewAnimation("RunningAnim", GetAnimationId("RunningAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("WalkingAnim", GetAnimationId("WalkingAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("JumpingAnim", GetAnimationId("JumpingAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("FallingAnim", GetAnimationId("FallingAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("ClimbingAnim", GetAnimationId("ClimbingAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("SwimmingAnim", GetAnimationId("SwimmingAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("SwimmingIdleAnim", GetAnimationId("SwimmingIdleAnim"), Enum.AnimationPriority.Idle, false)
	NewAnimation("ToolAnim", GetAnimationId("ToolAnim"), Enum.AnimationPriority.Movement, false)
	NewAnimation("SitAnim", GetAnimationId("SitAnim"), Enum.AnimationPriority.Movement, false)

	--Update the animations if they are changed
	for i, v in ipairs(AnimationsConfigFolder:GetChildren()) do
		v:GetPropertyChangedSignal("Value"):Connect(function()
			Animations[v.Name][1] = v.Value
			if Animations[v.Name][2] then
				RunAnimation(false, v.Name)
				RunAnimation(true, v.Name)
			end
		end)
		v:GetAttributeChangedSignal("Speed"):Connect(function()
			if Animations[v.Name][2] then
				Animations[v.Name][2]:AdjustSpeed(GetAnimationSpeed(v.Name))
			end
		end)
	end

	local function StopAllEmotes()
		for i, anim in pairs(Animations) do
			if anim[4] == true then --if is emote
				if anim[2] then --if track is playing
					anim[2]:Stop()
					anim[2] = nil
				end
			end
		end
	end

	RunAnimation(true, "IdleAnim")
	local LastChangedIdleAnim, CurrentIdleAnim = os.clock(), 1
	
	if game:GetService("RunService"):IsClient() then
		--For some reason, the idle animation 2 is broken on NPC's, so we'll only enable on client
		
		game:GetService("RunService").Heartbeat:Connect(function()
			if CurrentIdleAnim == 1 then
				if os.clock() - Config.TimeInBetweenIdleAnimationChange > LastChangedIdleAnim then
					CurrentIdleAnim = 2
					LastChangedIdleAnim = os.clock()
					RunAnimation(false, "IdleAnim")
					RunAnimation(true, "IdleAnim2")
				end
			else
				local IdleAnim2Length = Animations["IdleAnim2"][2] and Animations["IdleAnim2"][2].Length or 0
				if os.clock() - IdleAnim2Length > LastChangedIdleAnim then
					CurrentIdleAnim = 1
					LastChangedIdleAnim = os.clock()
					RunAnimation(false, "IdleAnim2")
					RunAnimation(true, "IdleAnim")
				end
			end
		end)
	end

	Humanoid().Running:Connect(function(speed)
		--Stops/starts the running animation if they stop/start moving, as there is no "idle" state
		StopAllEmotes()
		if speed < 1 then
			RunAnimation(false, "WalkingAnim")
			RunAnimation(false, "RunningAnim")
		else
			if speed > 17 then 
				RunAnimation(false, "WalkingAnim")
				RunAnimation(true, "RunningAnim")
				Animations["RunningAnim"][2]:AdjustSpeed(speed / 23)
			else
				RunAnimation(false, "WalkingAnim")
				RunAnimation(true, "WalkingAnim")
				Animations["WalkingAnim"][2]:AdjustSpeed(speed / 11)
			end
		end
	end)
	Humanoid().Swimming:Connect(function(speed)
		StopAllEmotes()
		if speed < 1 then
			RunAnimation(false, "SwimmingAnim")
			RunAnimation(true, "SwimmingIdleAnim")
		else
			RunAnimation(true, "SwimmingAnim")
			RunAnimation(false, "SwimmingIdleAnim")
		end
	end)

	Humanoid().Climbing:Connect(function(speed)
		--Pauses the climbing animation if they stop moving while climbing
		StopAllEmotes()
		if Animations["ClimbingAnim"][2] then
			if speed == 0 then
				Animations["ClimbingAnim"][2]:AdjustSpeed(0)
			else
				Animations["ClimbingAnim"][2]:AdjustSpeed(GetAnimationSpeed("ClimbingAnim") * speed / 5)
			end
		end
	end)

	local function ToolIsEquipped()
		--Play tool equipped animation if tool is equipped
		if Config.PlayToolEquippedAnimation == true then
			local IsEquipped = false
			for i, v in ipairs(Humanoid().Parent:GetChildren()) do
				if v:IsA("Tool") then
					IsEquipped = true
					break
				end
			end
			RunAnimation(IsEquipped, "ToolAnim")
		end
	end
	Humanoid().Parent.ChildAdded:Connect(ToolIsEquipped)
	Humanoid().Parent.ChildRemoved:Connect(ToolIsEquipped)
	ToolIsEquipped()


	Humanoid():SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
	Humanoid().StateChanged:Connect(function(OldState, NewState)
		if Config.Debug == true then
			print(OldState.Name .. " --> " .. NewState.Name)
		end

		StopAllEmotes()
		
		RunAnimation(false, "RunningAnim")
		RunAnimation(false, "ClimbingAnim")
		RunAnimation(false, "JumpingAnim")
		RunAnimation(false, "FallingAnim")
		RunAnimation(false, "SwimmingAnim")
		RunAnimation(false, "SwimmingIdleAnim")
		RunAnimation(false, "SitAnim")

		if NewState == Enum.HumanoidStateType.Climbing then
			RunAnimation(true, "ClimbingAnim")
		elseif NewState == Enum.HumanoidStateType.Running then
			if Humanoid().MoveDirection ~= Vector3.new() then
				RunAnimation(true, "RunningAnim")
			end
		elseif NewState == Enum.HumanoidStateType.Freefall then
			RunAnimation(true, "JumpingAnim")
		elseif NewState == Enum.HumanoidStateType.Swimming then
			if Humanoid().MoveDirection ~= Vector3.new() then
				RunAnimation(true, "SwimmingAnim")
			end
		elseif NewState == Enum.HumanoidStateType.Seated then
			RunAnimation(true, "SitAnim")
		end
	end)


	--EMOTES

	NewAnimation("DanceAnim", 507771019, Enum.AnimationPriority.Action, true)
	NewAnimation("Dance2Anim", 507776043, Enum.AnimationPriority.Action, true)
	NewAnimation("Dance3Anim", 507777268, Enum.AnimationPriority.Action, true)
	NewAnimation("LaughAnim", 507770818, Enum.AnimationPriority.Action, true, false)
	NewAnimation("PointAnim", 507770453, Enum.AnimationPriority.Action, true, false)
	NewAnimation("WaveAnim", 507770239, Enum.AnimationPriority.Action, true, false)
	NewAnimation("CheerAnim", 507770677, Enum.AnimationPriority.Action, true, false)
	NewAnimation("PoseAnim", 5392107832, Enum.AnimationPriority.Action, true)
	
	local ChattedEvent = Config.ChattedEvent
	if not ChattedEvent and Player() then
		ChattedEvent = Player().Chatted
	end
	if ChattedEvent then
		ChattedEvent:Connect(function(message)
			if Config.AllowEmotes == true then
				if message:lower() == "/e dance" then
					RunAnimation(true, "DanceAnim")
				elseif message:lower() == "/e dance2" then
					RunAnimation(true, "Dance2Anim")
				elseif message:lower() == "/e dance3" then
					RunAnimation(true, "Dance3Anim")

				elseif message:lower() == "/e laugh" then
					RunAnimation(true, "LaughAnim")
				elseif message:lower() == "/e point" then
					RunAnimation(true, "PointAnim")
				elseif message:lower() == "/e pose" then
					RunAnimation(true, "PoseAnim")
				elseif message:lower() == "/e wave" then
					RunAnimation(true, "WaveAnim")
				elseif message:lower() == "/e cheer" then
					RunAnimation(true, "CheerAnim")
				end
			end
		end)
	end
end