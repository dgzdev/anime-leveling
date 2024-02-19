export type Rank = "E" | "D" | "C" | "B" | "A" | "S"
export type SubRank = "I" | "II" | "III" | "IV" | "V"
export type World = "World 1" | "World 2"
export type WeaponType = "Sword" | "Bow" | "Staff"
export type PlayerData = {
	rank: Rank,
	subRank: SubRank,

	Level: number,
	Experience: number,
	Gold: number,
	Equiped: string,

	Inventory: {
		[string]: {
			AchiveDate: number,
			Rank: Rank,
		},
	},
	Skills: { [string]: {
		AchiveDate: number | nil,
		Level: number,
	} },

	World: World,
	Points: {
		Inteligence: number,
		Strength: number,
		Agility: number,
		Endurance: number,
	},
}

local ProfileTemplate: PlayerData = {
	rank = "E",
	subRank = "I",

	Equiped = "Wooden_Sword",

	Level = 1,
	Experience = 0,
	Gold = 0,

	Inventory = {},
	Skills = {},

	World = "World 1",

	Points = {
		Inteligence = 1,
		Strength = 1,
		Agility = 1,
		Endurance = 1,
	},
}

return {
	profileKey = "PLAYER_DATA",
	profileTemplate = ProfileTemplate,
	defaultInventory = {
		["Wooden_Sword"] = {
			AchiveDate = os.time(),
			Rank = "E",
		},
	},
	gameWeapons = {
		["Wooden_Sword"] = {
			Type = "Sword",
			Damage = 10,
		},
	},
}
