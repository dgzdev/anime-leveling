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
				["FaceAccessory"] = 14579692783,
				["HairAccessory"] = 15633971750,
				["BackAccessory"] = 0,
				["WaistAccessory"] = 0,
				["ShouldersAccessory"] = 0,
				["NeckAccessory"] = 0,
				["HatAccessory"] = 0,
				["Shirt"] = 11321632482,
				["Pants"] = 7730552127,
				["Colors"] = { 255, 204, 153 },
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
