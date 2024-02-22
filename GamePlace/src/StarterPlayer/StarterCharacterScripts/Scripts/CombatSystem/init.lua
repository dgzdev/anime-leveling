local ContentProvider = game:GetService("ContentProvider")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local CombatSystem = {}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local AttackButtons = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Gamepad1 }
local DefendButtons = { Enum.UserInputType.MouseButton2, Enum.UserInputType.Gamepad2 }

local Combat = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Combat") :: RemoteFunction

if not (Players:GetAttribute("Loaded")) then
	Players:GetAttributeChangedSignal("Loaded"):Wait()
end

local Attack = require(script:WaitForChild("Attack"))
local Defense = require(script:WaitForChild("Defense"))

function CombatSystem:Defend(state: "Start" | "End")
	if Humanoid.Health > 0 then
		local properties = Combat:InvokeServer("Defend", state)
		if not properties then
			return
		end
	end
end

ContextActionService:BindAction("Attack", function(action, state, input)
	if state == Enum.UserInputState.Begin then
		Workspace:SetAttribute("Attacking", true)
	elseif state == Enum.UserInputState.End then
		Workspace:SetAttribute("Attacking", false)
	end
end, true, table.unpack(AttackButtons))

ContextActionService:BindAction("Defend", function(action, state, input)
	if state == Enum.UserInputState.Begin then
		CombatSystem:Defend("Start")
	elseif state == Enum.UserInputState.End then
		CombatSystem:Defend("End")
	end
end, true, table.unpack(DefendButtons))

task.spawn(function()
	Attack:Init()
	Defense:Init()
end)

return CombatSystem
