export type Rank = "E" | "D" | "C" | "B" | "A" | "S"
export type SubRank = "I" | "II" | "III" | "IV" | "V"
export type World = "World 1" | "World 2"
export type PlayerData = {
	["Slots"]: {
		["1"]: {
			Character: {
				Acessories: {
					Order: number,
					AssetId: number,
					Puffiness: number,
					AccessoryType: Enum.AccessoryType,
				},
				Clothes: {
					Shirt: number,
					Pants: number,
				},
				Face: string,
				BodyColor: { number },
			},
		} | boolean,
		["2"]: {
			Character: {
				Acessories: {
					Order: number,
					AssetId: number,
					Puffiness: number,
					AccessoryType: Enum.AccessoryType,
				},
				Clothes: {
					Shirt: number,
					Pants: number,
				},
				Face: string,
				BodyColor: { number },
			},
		} | boolean,
		["3"]: {
			Character: {
				Acessories: {
					Order: number,
					AssetId: number,
					Puffiness: number,
					AccessoryType: Enum.AccessoryType,
				},
				Clothes: {
					Shirt: number,
					Pants: number,
				},
				Face: true | false | "string",
				BodyColor: { number },
			},
		} | boolean,
		["4"]: {
			Character: {
				Acessories: {
					Order: number,
					AssetId: number,
					Puffiness: number,
					AccessoryType: Enum.AccessoryType,
				},
				Clothes: {
					Shirt: number,
					Pants: number,
				},
				Face: string,
				BodyColor: { number },
			},
		} | "false",
	},
	["Selected_Slot"]: string,
}
local ProfileTemplate: PlayerData = {
	["Slots"] = {
		["1"] = {
			["Character"] = {
				["Acessories"] = {
					{
						Order = 1,
						AssetId = 14579692783,
						Puffiness = 0.5,
						AccessoryType = "Face",
					},
					{
						Order = 2,
						AssetId = 15633971750,
						Puffiness = 0.5,
						AccessoryType = "Hair",
					},
				},
				["Clothes"] = {
					["Shirt"] = 7730552127,
					["Pants"] = 11321632482,
				},
				["Face"] = true,
				["BodyColor"] = { 255, 204, 153 },
			},
		},
		["2"] = "false",
		["3"] = "false",
		["4"] = "false",
	},
	["Selected_Slot"] = "1",
}

return {
	profileKey = "TESTING_DATA_1",
	profileTemplate = ProfileTemplate,
}
