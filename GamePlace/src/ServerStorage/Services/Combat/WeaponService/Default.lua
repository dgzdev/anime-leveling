local Default = {}

function Default.Attack(Character: Model, InputState: Enum.UserInputState, p: { Position: CFrame }) end

function Default.Defense(Character: Model, InputState: Enum.UserInputState, p: { Position: CFrame })
	if InputState == Enum.UserInputState.Begin then
		Character:SetAttribute("Defense", true)
	elseif InputState == Enum.UserInputState.End then
		Character:SetAttribute("Defense", false)
	end
end

function Default.Start() end

return Default
