local Selection = game:GetService("Selection")

local tool = Instance.new("Tool", workspace)
tool.Name = "Undefined"

tool.RequiresHandle = false
tool.Enabled = true

tool.Grip = CFrame.new(
	0.725000024,
	0.00200000009,
	-0.354000002,
	-0.00830843206,
	0.976898074,
	-0.213543966,
	-0.999151468,
	-0.0167251024,
	-0.0376378633,
	-0.040339902,
	0.213050067,
	0.97620815
)

local cam = workspace.CurrentCamera
local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 100)

for _, model: Model in Selection:Get() do
	tool.Name = model.Name
	for _, a in model:GetChildren() do
		a.Parent = tool
	end

	model:Destroy()
end

if ray then
	tool:PivotTo(CFrame.new(ray.Position))
else
	tool:PivotTo(CFrame.new(cam.CFrame.Position + cam.CFrame.LookVector * 10))
end

Selection:Add({ tool })
