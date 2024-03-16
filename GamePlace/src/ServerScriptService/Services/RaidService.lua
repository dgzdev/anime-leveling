local TeleportService = game:GetService("TeleportService")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--> services, controllers
local RaidService = Knit.CreateService({
	Name = "RaidService",
	Client = {},
})

local Zone = require(game.ReplicatedStorage.Modules.Zone)

local Areas = {
	["Zone1"] = {
		Time = 20,
		Limit = 4,
		Minimum = 4,
	},

	["Zone2"] = {
		Time = 15,
		Limit = 5,
		Minimum = 5,
	},

	["Zone3"] = {
		Time = 10,
		Limit = 1,
		Minimum = 1,
	},
}

--[[
    player ele pedisse pra entrar na area,
    ele vai ser adicionado na area
    e vai ser avisado que ele entrou na area

    dps do tempo acabar, ele vai ser removido da area
    e teleportado pra raid
]]

local ZonesFolder: Folder = game.Workspace:FindFirstChild("Raids")

function RaidService:QueryControl(
	players: Players,
	signal: boolean,
	time: number,
	zoneBillboard: BillboardGui,
	bool: BoolValue
) --> Começa a contar a partir do momento que tem 5 players
	local textlabel: TextLabel = zoneBillboard:FindFirstChild("TextLabel")

	local thread = task.spawn(function()
		for i = time, 1, -1 do
			if bool.Value == true then
				break
			end

			textlabel.Text = i
			task.wait(1)
		end
		textlabel.Text = "Loading dungeon..."

		RaidService:TeleportToPlace(players)
	end)
	bool:GetPropertyChangedSignal("Value"):Once(function()
		if bool.Value == true then
			task.cancel(thread)
		end
	end)
end

function RaidService:TeleportToPlace(players: Players)
	local reserved = TeleportService:ReserveServer(16760466880)
	print(players)
	TeleportService:TeleportToPrivateServer(16760466880, reserved, players)
end

function RaidService:Init()
	task.spawn(function()
		for _, z: BasePart in ZonesFolder:GetChildren() do
			local zonemanager = Zone.new(z) --> part, folder, model
			local billboard = ReplicatedStorage.Models.UI.RaidBillboard:Clone()
			billboard.Parent = z
			billboard.TextLabel.Text = "0" .. "/" .. Areas[z.Name].Limit
			billboard.Require.Text = "MINIMUM: " .. Areas[z.Name].Minimum 
			local shouldBreak = Instance.new("BoolValue")
			zonemanager.playerEntered:Connect(function(player: Player)
				local playersArray = zonemanager:getPlayers()

				if #playersArray > Areas[z.Name].Limit then
					shouldBreak.Value = true
					billboard.TextLabel.Text = "Limit Exceeded"
					return
				end

				if #playersArray <= Areas[z.Name].Limit and #playersArray >= Areas[z.Name].Minimum then
					shouldBreak.Value = false
					RaidService:QueryControl(playersArray, true, Areas[z.Name].Time, billboard, shouldBreak)
					print("teleporting? countdown test", playersArray)
				end

				billboard.TextLabel.Text = #playersArray .. "/" .. Areas[z.Name].Limit
				print(playersArray)
			end)

			zonemanager.playerExited:Connect(function(player: Player)
				local playersArray = zonemanager:getPlayers()

				if #playersArray < Areas[z.Name].Minimum then
					shouldBreak.Value = true
				end

				task.wait(1)

				billboard.TextLabel.Text = #playersArray .. "/" .. Areas[z.Name].Limit
				print(playersArray)
			end)
		end
	end)
end

function RaidService.KnitInit()
	--> knit ta iniciado
	RaidService:Init()
end

return RaidService
