return {
	Name = "Default",
	Rarity = "Common",
	Model = nil, --> Add a model here
	Description = "This is a default item.",
	Weight = 1,
	Requirements = {
		Level = 1,
	},
	Use = {
		Type = "Consumable", --> Consumable, Equipable, etc.
		Effect = function(player)
			-- Code here
		end,
		Uses = 1,
	},
}
