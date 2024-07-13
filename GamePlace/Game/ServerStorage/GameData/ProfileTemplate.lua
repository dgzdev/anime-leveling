return {
	Slots = {
		[1] = {
			["Character"] = {
				["Shirt"] = {
					Id = 1,
					Color = "#ff0000",
				},
				["Pants"] = {
					Id = 1,
					Color = "#ff0000",
				},
				["Shoes"] = {
					Id = 1,
					Color = "#ff0000",
				},
				["Hair"] = {
					Id = 1,
					Color = "#ff0000",
				},
				["Colors"] = { 255, 204, 153 },
			},

			["Location"] = "Character Creation",
			["LastJoin"] = os.date("%x"),
			["Data"] = {
				["Level"] = 1,

				["Experience"] = 0,

				["Gold"] = 0,

				["Equiped"] = {
					["Weapon"] = "Fists",
					["Id"] = 1,
				},

				["Quests"] = {},
				["Hotbar"] = { 1 },
				["Inventory"] = {
					["Fists"] = {
						AchiveDate = os.time(),
						Rank = "E",
						Id = 1,
					},
					
				},
				["SkillsTreeUnlocked"] = { ["1"] = true },

				["PointsAvailable"] = 0,
				["Points"] = {
					["Intelligence"] = 0,
					["Strength"] = 0,
					["Agility"] = 0,
					["Endurance"] = 0,
					["Sense"] = 0,
				},
			},
		},
		[2] = "false",
		[3] = "false",
		[4] = "false",
	},
	Selected_Slot = 1,
}
