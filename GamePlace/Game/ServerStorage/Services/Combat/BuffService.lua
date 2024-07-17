local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GameData = require(ServerStorage.GameData)

local PlayerService

local BuffService = Knit.CreateService({
	Name = "BuffService",
	Client = {},
})

function BuffService:GetAppliedBuffsToPlayer(Player)
	local PlayersBuffed = {}
	for i, v in pairs(GameData.playerEffects.Buffs) do
		if v.UsersAffected[Player.Name] then
			PlayersBuffed[i] = v.UsersAffected[Player.Name]
		end
	end
	return PlayersBuffed
end

function BuffService:ApplyBuffToPlayer(Player: Player, BuffType: string, Info: { [string]: any }) ---Example: Info = {DamageMultiplier = 1.3, Time = 60}
	if not BuffType then
		return
	end
	if not Info.Time then
		return
	end
	if not GameData.playerEffects.Buffs[BuffType] then
		warn("This BuffType doesnt exist: ", BuffType)
		return
	end

	local UsersAffected = GameData.playerEffects.Buffs[BuffType].UsersAffected
	local callback = GameData.playerEffects.Buffs[BuffType].callback

	local DamageMultiplied = callback(Player, Info)

	if UsersAffected[Player.Name] then
		if UsersAffected[Player.Name].DamageMultiplier and DamageMultiplied then
			if UsersAffected[Player.Name].DamageMultiplier < DamageMultiplied then
				UsersAffected[Player.Name].DamageMultiplier = DamageMultiplied
				if UsersAffected[Player.Name].Time and Info.Time then
					UsersAffected[Player.Name].Time = Info.Time
				end
			end
		end
	else
		UsersAffected[Player.Name] = Info
		UsersAffected[Player.Name].CurrentTime = Info.Time
		coroutine.wrap(function()
			repeat
				task.wait(1)

				if
					Info.Time
					and Info.Time > UsersAffected[Player.Name].Time
					and Info.Time > UsersAffected[Player.Name].CurrentTime
				then
					UsersAffected[Player.Name].CurrentTime = Info.Time
					UsersAffected[Player.Name].Time = Info.Time
					Info.Time = nil
				end

				UsersAffected[Player.Name].CurrentTime -= 1
			until UsersAffected[Player.Name].CurrentTime <= 0
		end)()
	end
end

function BuffService.KnitStart()
	PlayerService = Knit.GetService("PlayerService")
end

return BuffService
