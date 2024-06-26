local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Player = game.Players.LocalPlayer :: Player
local FadeFrame = Player.PlayerGui.FadeEffect:WaitForChild("Frame") :: Frame
local UPBAR = Player.PlayerGui.Cutscene:WaitForChild("UP")
local DOWNBAR = Player.PlayerGui.Cutscene:WaitForChild("DOWN")
local Dialogs = Player.PlayerGui.Cutscene:WaitForChild("Dialogs")

local CurrentDialog: Frame?
local DramaticController = Knit.CreateController({
	Name = "DramaticController",
})

local CameraController

export type CameraAnimation = {
	ClassName: "Folder",
	Name: string,
	Frames: {
		ClassName: "Folder",
		Name: string,

		[number]: {
			ClassName: "CFrameValue",
			Value: CFrame,
			Name: number,
		},
	},
	FOV: {
		ClassName: "Folder",
		Name: string,

		[number]: {
			ClassName: "NumberValue",
			Value: number,
			Name: number,
		},
	},
}

function lerp(start, goal, alpha)
	return start + (goal - start) * alpha
end

-- Animate Camera
function DramaticController:AnimateCamera(animation: CameraAnimation, yield: boolean?)
	yield = yield or false

	assert(animation, "Missing argument #1: animation")
	assert(animation.ClassName == "Folder", "Argument #1 must be a Folder")

	local FrameFolder = animation:FindFirstChild("Frames")
	assert(FrameFolder, "Missing child 'Frames' in argument #1: animation")
	assert(FrameFolder.ClassName == "Folder", "Child 'Frames' in argument #1 must be a Folder")

	local FovFolder = animation:FindFirstChild("FOV")
	assert(FovFolder, "Missing child 'FOV' in argument #1: animation")
	assert(FovFolder.ClassName == "Folder", "Child 'FOV' in argument #1 must be a Folder")

	CameraController:DisableCamera()

	Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

	local TargetCFrame = Workspace.CurrentCamera.CFrame
	local TargetFOV = Workspace.CurrentCamera.FieldOfView

	RunService:BindToRenderStep("Cutscene", Enum.RenderPriority.Camera.Value, function()
		Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame:Lerp(TargetCFrame, 0.5)
		Workspace.CurrentCamera.FieldOfView = lerp(Workspace.CurrentCamera.FieldOfView, TargetFOV, 0.5)
	end)

	local function renderFrame(_, frame)
		assert(frame.ClassName == "CFrameValue", "Child in 'Frames' must be a CFrameValue")

		TargetCFrame = frame.Value

		local fovChange = FovFolder:FindFirstChild(tostring(_))
		if fovChange then
			assert(fovChange.ClassName == "NumberValue", "Child in 'Fov' must be a NumberValue")
			TargetFOV = fovChange.Value
		end
	end

	local Frames = FrameFolder:GetChildren()
	table.sort(Frames, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	if yield then
		for i, frame in Frames do
			renderFrame(i, frame)
			task.wait(1 / 60)
		end

		CameraController:EnableCamera()
		RunService:UnbindFromRenderStep("Cutscene")
	else
		task.spawn(function()
			for i, frame in Frames do
				renderFrame(i, frame)
				task.wait(1 / 60)
			end

			CameraController:EnableCamera()
			RunService:UnbindFromRenderStep("Cutscene")
		end)
	end
end

-- PlayAnimationInCharacter
function DramaticController:PlayAnimationInCharacter() end

-- LockCharacterr
function DramaticController:LockCharacter()
	Player.Character.HumanoidRootPart.Anchored = true
end

-- UnlockCharacter
function DramaticController:UnlockCharacter()
	Player.Character.HumanoidRootPart.Anchored = false
end

-- FADE IN
function DramaticController:FadeIn(time: number?, yield: boolean?)
	time = time or 1 --> tempo padrão de 1 segundo
	yield = yield or false --> padrão de não esperar o término

	local Tinfo = TweenInfo.new(time, Enum.EasingStyle.Sine)

	local Tween = TweenService:Create(FadeFrame, Tinfo, { BackgroundTransparency = 1 }) :: Tween
	Tween:Play()

	if yield then
		Tween.Completed:Wait()
	end
end
-- FADE OUT
function DramaticController:FadeOut(time: number?, yield: boolean?)
	time = time or 1 --> tempo padrão de 1 segundo
	yield = yield or false --> padrão de não esperar o término
	local Finished = false
	local Tinfo = TweenInfo.new(time, Enum.EasingStyle.Sine)
	local Tween = TweenService:Create(FadeFrame, Tinfo, { BackgroundTransparency = 0 }) :: Tween

	Tween:Play()
	if yield then
		Tween.Completed:Wait()
	end
end

-- SHOW DIALOG
function DramaticController:ShowCutsceneBars()
	local Tinfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
	local TweenUp = TweenService:Create(UPBAR, Tinfo, { Position = UDim2.fromScale(0, 0) }) :: Tween
	local TweenDown = TweenService:Create(DOWNBAR, Tinfo, { Position = UDim2.fromScale(0, 1) })

	TweenUp:Play()
	TweenDown:Play()

	TweenUp.Completed:Wait()
end

function DramaticController:HideCutsceneBars()
	local Tinfo = TweenInfo.new(2, Enum.EasingStyle.Sine)
	local TweenUp = TweenService:Create(UPBAR, Tinfo, { Position = UDim2.fromScale(0, -1) }) :: Tween
	local TweenDown = TweenService:Create(DOWNBAR, Tinfo, { Position = UDim2.fromScale(0, 1.5) })

	TweenUp:Play()
	TweenDown:Play()

	TweenUp.Completed:Wait()
end

-- SHOW DIALOG
function DramaticController:ShowDialogs(text: string, time: number?, reverses: boolean?)
	assert(text, "Missing argument #1: text")
	assert(type(text) == "string", "Argument #1 must be a string")

	reverses = reverses or false
	time = time or 1 --> tempo padrão de 1 segundo

	local Tinfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	if CurrentDialog then
		local TweenD =
			TweenService:Create(CurrentDialog.Frame, Tinfo, { Position = UDim2.fromScale(0.5, 0.6) }) :: Tween
		TweenD:Play()
	end

	local DialogsClone = Dialogs:Clone() :: Frame
	DialogsClone.Parent = Dialogs.Parent

	DialogsClone.Position = UDim2.fromScale(0.5, 1)

	local DialogText = DialogsClone.DialogTemplate :: TextLabel
	local TextStroke = DialogText:FindFirstChild("UIStroke") :: UIStroke
	local TweenTS = TweenService:Create(TextStroke, Tinfo, { Transparency = 0 }) :: Tween
	local TweenD = TweenService:Create(DialogsClone, Tinfo, { Position = UDim2.fromScale(0.5, 0.65) }) :: Tween
	local TweenText = TweenService:Create(DialogText, Tinfo, { TextTransparency = 0 }) :: Tween

	DialogText.Text = text

	CurrentDialog = {
		Frame = DialogsClone,
		time = time,
	}

	TweenTS:Play()
	TweenText:Play()
	TweenD:Play()

	TweenTS.Completed:Wait()
	task.delay(time, function()
		local TweenTS = TweenService:Create(TextStroke, Tinfo, { Transparency = 1 }) :: Tween
		local TweenText = TweenService:Create(DialogText, Tinfo, { TextTransparency = 1 }) :: Tween
		TweenText:Play()
		TweenTS:Play()

		TweenTS.Completed:Wait()
		DialogsClone:Destroy()
	end)
end

task.spawn(function()
	task.wait(10)
	local QuestDialog1 = function()
		DramaticController:LockCharacter()
		DramaticController:ShowCutsceneBars()

		DramaticController:AnimateCamera(game.ReplicatedStorage.CameraAnimations["Portal Leave"], false)

		DramaticController:ShowDialogs("Olá, eu sou um NPC", 2)
		task.wait(2)
		DramaticController:ShowDialogs("Estou aqui para te ajudar", 1)
		task.wait(2)
		DramaticController:ShowDialogs("Você pode me ajudar?", 2)
		task.wait(2)

		DramaticController:HideCutsceneBars()
		DramaticController:UnlockCharacter()
	end

	QuestDialog1()
end)

function DramaticController.KnitInit()
	CameraController = Knit.GetController("CameraController")
end

return DramaticController
