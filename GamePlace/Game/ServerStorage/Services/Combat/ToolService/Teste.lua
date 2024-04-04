return {
	name = "Teste",
	description = "Teste",

	Activated = function(Tool: Tool, ...)
		print("teste", Tool)
	end,

	Equipped = function(Tool: Tool, ...)
		print("equip")
	end,

	Unequipped = function(Tool: Tool, ...)
		print("unequip")
	end,
}
