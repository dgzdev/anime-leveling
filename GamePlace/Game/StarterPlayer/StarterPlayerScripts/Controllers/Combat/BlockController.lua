local Knit = require(game.ReplicatedStorage.Packages.Knit)

local BlockController = Knit.CreateController({
	Name = "BlockController",
})

local WeaponService
local RenderController

local ContextActionService = game:GetService("ContextActionService")

local Binded = false
local Validate = require(game.ReplicatedStorage.Validate)
local Player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

function BlockController:BindBlock()
	ContextActionService:BindAction("Block", function(_, inputState)
		local Character = Player.Character
		local Humanoid = Character.Humanoid

		if inputState == Enum.UserInputState.Begin then
			if not Validate:CanBlock(Humanoid) then
				repeat
					task.wait()
				until Validate:CanBlock(Humanoid) or not UserInputService:IsKeyDown(Enum.KeyCode.F)
			end

			if not UserInputService:IsKeyDown(Enum.KeyCode.F) then
				return
			end
			
			WeaponService:Block(true)
		elseif inputState == Enum.UserInputState.End then
			RenderController:StopAnimationMatch(Humanoid, "Block")
			WeaponService:Block(false)
		end
	end, true, Enum.KeyCode.F)
end

function BlockController:UnbindBlock()
	ContextActionService:UnbindAction("Block")
	WeaponService:Block(false)
end

function BlockController.KnitInit()
	RenderController = Knit.GetController("RenderController")
	WeaponService = Knit.GetService("WeaponService")
end

return BlockController
