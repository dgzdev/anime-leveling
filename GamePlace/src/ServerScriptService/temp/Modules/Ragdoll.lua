local Ragdoll = {}

function Ragdoll:Create(target: Model)
	target.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
	target.PrimaryPart.AssemblyAngularVelocity = Vector3.new()
	target.PrimaryPart.Anchored = true
	task.wait(0.1)
	target.PrimaryPart.Anchored = false

	for _, joint: Motor6D | BasePart in ipairs(target:GetDescendants()) do
		if joint:IsA("Motor6D") then
			local socket = Instance.new("BallSocketConstraint", joint.Parent)
			local att0 = Instance.new("Attachment", joint.Part0)
			local att1 = Instance.new("Attachment", joint.Part1)

			att0.CFrame = joint.C0
			att1.CFrame = joint.C1

			socket.Attachment0 = att0
			socket.Attachment1 = att1

			socket.TwistLimitsEnabled = false
			socket.LimitsEnabled = false

			joint.Enabled = false
		end
	end
end

return Ragdoll
