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
	profileKey = "DEVELOPMENT_7",
	profileTemplate = ProfileTemplate,
}
