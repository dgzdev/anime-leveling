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

local BlockKeys = { Enum.KeyCode.F, Enum.KeyCode.ButtonR1 }

function BlockController:BindBlock()
	ContextActionService:BindAction("Block", function(_, inputState, object: InputObject)
		local Character = Player.Character
		local Humanoid = Character.Humanoid

		local isKeyDown = function()
			for index, key in BlockKeys do
				if UserInputService:IsKeyDown(key) then
					return true
				end
				if UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, key) then
					return true
				end
			end
			return false
		end

		if inputState == Enum.UserInputState.Begin then
			if not Validate:CanBlock(Humanoid) then
				repeat
					task.wait()
				until Validate:CanBlock(Humanoid) or not isKeyDown()
			end

			for index, key in BlockKeys do
				if isKeyDown() then
					WeaponService:Block(true)
					break
				end
			end

			WeaponService:Block(true)
		elseif inputState == Enum.UserInputState.End then
			RenderController:StopAnimationMatch(Humanoid, "Block")
			WeaponService:Block(false)
		end
	end, true, table.unpack(BlockKeys))
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
