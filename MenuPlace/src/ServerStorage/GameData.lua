local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type Rank = "E" | "D" | "C" | "B" | "A" | "S"
export type SubRank = "I" | "II" | "III" | "IV" | "V"
export type World = "World 1" | "World 2"
export type WeaponType = "Sword" | "Bow" | "Staff"
export type ProfileData = {
	Slots: {
		[number]: PlayerSlot | string,
	},
	Selected_Slot: number,
}
export type PlayerSlot = {
	Character: {
		FaceAccessory: number,
		HairAccessory: number,
		BackAccessory: number,
		WaistAccessory: number,
		ShouldersAccessory: number,
		NeckAccessory: number,
		HatAccessory: number,
		Shirt: number,
		Pants: number,
		Colors: { number },
	},
	Location: string | "Character Creation",
	LastJoin: string,

	Data: {
		Level: number,

		Experience: number,
		Mana: number,

		Gold: number,
		Equiped: {
			Weapon: string,
			Id: number,
		},
		Hotbar: { number },
		Inventory: Inventory,
		Skills: { [string]: {
			AchiveDate: number | nil,
			Level: number,
		} },
		Points: {
			Inteligence: number,
			Strength: number,
			Agility: number,
			Endurance: number,
		},
	},
}
export type SlotData = {
	Level: number,

	Experience: number,
	Mana: number,

	Gold: number,

	Equiped: {
		Weapon: string,
		Id: number,
	},
	Quests: {},
	Hotbar: { number },
	Inventory: Inventory,
	Skills: { [string]: {
		AchiveDate: number | nil,
		Level: number,
	} },
	Points: {
		Inteligence: number,
		Strength: number,
		Agility: number,
		Endurance: number,
	},
}
export type Inventory = {
	[string]: {
		AchiveDate: number,
		Rank: Rank,
		SubRank: SubRank,
		Id: number,
	},
}
local ProfileTemplate: ProfileData = {
	Slots = {
		[1] = {
			["Character"] = {
				["Shirt"] = {
					Id = 1,
					Color = { 255, 0, 0 },
				},
				["Pants"] = {
					Id = 1,
					Color = { 0, 0, 255 },
				},
				["Shoes"] = {
					Id = 1,
					Color = { 0, 255, 0 },
				},
				["Hair"] = {
					Id = 1,
					Color = { 255, 255, 0 },
				},
				["Colors"] = { 255, 204, 153 },
			},
			["Location"] = "Character Creation",
			["LastJoin"] = os.date("%x"),
			["Data"] = {
				["Level"] = 1,

				["Experience"] = 0,
				["Mana"] = 50,

				["Gold"] = 0,

				["Equiped"] = {
					["Weapon"] = "Melee",
					["Id"] = 1,
				},
				["Quests"] = {},
				["Hotbar"] = { 1, 3, 4, 5 },
				["Inventory"] = {
					["Melee"] = {
						AchiveDate = os.time(),
						Rank = "E",
						Id = 1,
					},
					["Starter Sword"] = {
						AchiveDate = os.time(),
						Rank = "E",
						Id = 2,
					},
					["Iron Starter Sword"] = {
						AchiveDate = os.time(),
						Rank = "E",
						Id = 3,
					},
					["Luxury Sword"] = {
						AchiveDate = os.time(),
						Rank = "D",
						Id = 4,
					},
					["King's Longsword"] = {
						AchiveDate = os.time(),
						Rank = "S",
						Id = 5,
					},
				},
				["Skills"] = {
					["Inteligence"] = {
						["AchiveDate"] = os.time(),
						["Level"] = 1,
					},
					["Strength"] = {
						["AchiveDate"] = os.time(),
						["Level"] = 1,
					},
					["Agility"] = {
						["AchiveDate"] = os.time(),
						["Level"] = 1,
					},
					["Endurance"] = {
						["AchiveDate"] = os.time(),
						["Level"] = 1,
					},
				},
				["Points"] = {
					["Inteligence"] = 0,
					["Strength"] = 0,
					["Agility"] = 0,
					["Endurance"] = 0,
				},
			},
		},
		[2] = "false",
		[3] = "false",
		[4] = "false",
	},
	Selected_Slot = 1,
}

local function CreateHumanoidDescription(desc: { [string]: any }): HumanoidDescription
	local hd = Instance.new("HumanoidDescription")

	for index, value in pairs(desc) do
		hd[index] = value
	end
	return hd
end

return {
	profileKey = "DEVELOPMENT_2",
	profileTemplate = ProfileTemplate,
	CharacterCustomization = {
		["HairAccessory"] = {
			15633971750,
			10396796837,
			15852318340,
			6823411442,
			6742023407,
			7865576321,
			10752635160,
			10781704042,
			8918767885,
			15772291062,
			14206947733,
			14959679659,
			15726608847,
			14618273768,
		},
		["BackAccessory"] = {
			12070660079,
			13129343460,
			6005669402,
			14077458498,
			16179410432,
			16188991498,
		},
		["NeckAccessory"] = {
			15993741162,
		},
		["Colors"] = {
			Color3.fromRGB(255, 204, 153),
			Color3.fromRGB(141, 85, 36),
			Color3.fromRGB(198, 134, 66),
			Color3.fromRGB(224, 172, 105),
			Color3.fromRGB(241, 194, 125),
			Color3.fromRGB(255, 219, 172),
			Color3.fromRGB(196, 159, 124),
			Color3.fromRGB(255, 202, 171),
			Color3.fromRGB(255, 233, 171),
			Color3.fromRGB(99, 76, 63),
			Color3.fromRGB(141, 105, 85),
		},
		["FaceAccessory"] = {
			14579692783,
			15885231323,
			13533964075,
			12600150456,
			15320182622,
			12214970207,
			15311194848,
			15057998509,
			14194512385,
			11259139803,
			4301204617,
			10756798024,
			5700329323,
		},
		["WaistAccessory"] = {},
		["ShouldersAccessory"] = { 16104389777, 15705130233, 16171910311 },
		["Shirt"] = {
			11321632482,
			8585425139,
			13223844566,
			2589153937,
			6554200369,
			6553589977,
			7080670551,
			5268607279,
			12208789572,
			14493610515,

			-- feminino

			-- random
			10634595330,
			7020184648,
			6312980803,
			6532610776,
			12115200454,
			7020522733,
		},
		["Pants"] = {
			7730552127,
			8585425372,
			13223845819,
			2025573793,
			6555797786,
			6555794614,
			11161065480,
			5268608819,
			12208793233,
			14971130800,

			-- feminino

			-- random
			13383050792,
			13764877470,
			14012149367,
			13773087547,
			6364675385,
			12380638156,
			12598478957,
			11023189766,
			8425223885,
			12953459257,
			12123500221,
			5258617858,
		},
		["HatAccessory"] = {
			10473471554,
			15653921024,
			12487648674,
			10797219014,
			15800524819,
			15235587512,
			10554380131,
			13700473642,
			13700473642,
			14951449917,
			14012017490,
			8346545669,
			10554380131,
			11330857059,
			6385209329,
			15414735755,
			6869986319,
		},
	},
}
