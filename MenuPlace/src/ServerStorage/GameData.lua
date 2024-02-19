export type Rank = "E" | "D" | "C" | "B" | "A" | "S"
export type SubRank = "I" | "II" | "III" | "IV" | "V"
export type World = "World 1" | "World 2"
export type PlayerData = {
	rank: Rank,
	subRank: SubRank,

	Level: number,
	Experience: number,
	Gold: number,

	Inventory: {
		[string]: number,
	},
	Skills: { [string]: {
		AchiveDate: number | nil,
		Level: number,
	} },

	World: World,
}

local ProfileTemplate: PlayerData = {
	rank = "E",
	subRank = "I",

	Level = 1,
	Experience = 0,
	Gold = 0,

	Inventory = {},
	Skills = {},

	World = "World 1",
}

return {
	profileKey = "PLAYER_DATA",
	profileTemplate = ProfileTemplate,
}
