local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ZoneManager = {}

local ZonePlus = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Zone"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

ZoneManager.ResetCharacter = function(self)
	local Spawn = Workspace:FindFirstChild("SpawnLocation", true)
	local Position = CFrame.new(-49, 3.6, -93) --> Default spawn location.
	if Spawn then --> If a spawn location is found, use that spawn location.
		Position = Spawn:GetPivot() * CFrame.new(0, 3, 0)
	elseif Spawn == nil then --> If no spawn location is found, use the default spawn location.
		warn("[ZONE] No spawn location found, using default spawn location.")
	end

	--> Reset character.
	Root.Anchored = true
	Character:PivotTo(Position)
	Root.Anchored = false
end
ZoneManager.Init = function(self) --> This initializes the ZoneManager.

end
ZoneManager.OnProfileReceive = function(self, Profile) end --> This is a stub, it's not used.

ZoneManager:Init() --> Initialize the ZoneManager.
return ZoneManager
