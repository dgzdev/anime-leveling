export type Rank = "E" | "D" | "C" | "B" | "A" | "S"
export type SubRank = "I" | "II" | "III" | "IV" | "V"
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
}

local ProfileTemplate: PlayerData = {
	rank = "E",
	subRank = "I",

	Level = 1,
	Experience = 0,
	Gold = 0,

	Inventory = {},
	Skills = {},
}

return {
	profileKey = "PLAYER_DATA",
	profileTemplate = ProfileTemplate,
}
