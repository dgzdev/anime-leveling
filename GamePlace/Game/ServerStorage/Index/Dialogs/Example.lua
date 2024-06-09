local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Example = {
	Normal = { -- dialog tree
		[1] = { -- sempre começa no index 1, branch
			npcName = "Example npc",
			npcText = "Hello, this is an example text, you are not supposed to see this.",
			Answers = {
				[1] = {
					text = "uh, i am a developer",
					NextDialog = 2,
					ValidateAnswer = function(Player)
						-- checagem para resposta, retornar true caso possa responder.
						-- manter pelomenos 1 botão que encerra o dialogo
						return false
					end,
				},
				[2] = { text = "why not?", NextDialog = 3 },
				[3] = { text = "all right, bye.." },
			},

			AnchorHumanoid = false, -- atributo que define se o humanoid vai ou não estar ancorado, padrão true
		},

		[2] = {
			npcName = "Example npc",
			npcText = "alr, take this tip then.",
			Answers = {
				[1] = {
					text = "ok",
					NextDialog = 4,
					callback = function(player)
						player:SetAttribute("Talked", true)
					end,
				},
			},
		},

		[3] = {
			npcName = "Example npc",
			npcText = "cuz its for devs only",
			Answers = {
				[1] = { text = "give me money", NextDialog = 5 },
			},
		},

		[4] = {
			npcName = "Example npc",
			npcText = "...",
			Answers = {
				[1] = { text = "bro, you are broke💀" },
			},
		},

		[5] = {
			npcName = "Example npc",
			npcText = "no",
			Answers = {
				[1] = { text = "..." },
			},
		},

		-- caso queria fazer alguma validação para receber essa arvore de dialogo, checar um item, atributo, etc
		validation = function(player)
			return true
		end,

		-- prioridade do dialogo, caso a validação de true em multiplos dialogos, será escolhido o com maior prioridade
		priority = 0,
	},

	Tipped = {
		[1] = { -- começa no index 1
			npcName = "Example npc",
			npcText = "Why are you still here?.",
			Answers = {
				[1] = { text = "..." },
			},
		},

		priority = 1,

		validation = function(player)
			return player:GetAttribute("Talked")
		end,
	},
}

return Example
