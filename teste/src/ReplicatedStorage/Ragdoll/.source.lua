local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LimbTree = require(script:WaitForChild("LimbTree"))

local PlayerEvents = ReplicatedStorage:WaitForChild("Player")

local Ragdoll = {}

function Ragdoll.RagdollCharacter(Character : Model)
	local Player = Players:GetPlayerFromCharacter(Character)
	
	if Player then
		PlayerEvents:WaitForChild("Ragdoll"):FireClient(Player, true)
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	Humanoid.AutoRotate = false
	
	if Humanoid.RigType == Enum.HumanoidRigType.R6 then
		local Head = Character:FindFirstChild("Head")
		local Torso = Character:FindFirstChild("Torso")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		local RightArm = Character:FindFirstChild("Right Arm")
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightLeg = Character:FindFirstChild("Right Leg")
		local LeftLeg = Character:FindFirstChild("Left Leg")
		
		--Neck
		
		if Torso and not Torso:FindFirstChild("NeckJoint") then
			local NeckAttachment = Instance.new("Attachment")
			NeckAttachment.Parent = Head
			NeckAttachment.Name = "NeckAttachment"
			NeckAttachment.Position = Vector3.new(0,-0.5,0)
			NeckAttachment.Orientation = Vector3.new(0,0,0)
			NeckAttachment:SetAttribute("Ragdoll", true)
			
			local TorsoNeckAttachment = Instance.new("Attachment")
			TorsoNeckAttachment.Parent = Torso
			TorsoNeckAttachment.Name = "TorsoNeckAttachment"
			TorsoNeckAttachment.Position = Vector3.new(0,1,0)
			TorsoNeckAttachment.Orientation = Vector3.new(0,0,0)
			TorsoNeckAttachment:SetAttribute("Ragdoll", true)
			
			local NeckJoint = script.Neck:Clone()
			NeckJoint.Parent = Torso
			NeckJoint.Name = "NeckJoint"
			NeckJoint.Attachment0 = NeckAttachment
			NeckJoint.Attachment1 = TorsoNeckAttachment
			NeckJoint:SetAttribute("Ragdoll", true)
			
			--Right Arm

			local RightArmAttachment = Instance.new("Attachment")
			RightArmAttachment.Parent = RightArm
			RightArmAttachment.Name = "RightArmAttachment"
			RightArmAttachment.Position = Vector3.new(-0.5,0.5,0)
			RightArmAttachment.Orientation = Vector3.new(0,0,0)
			RightArmAttachment:SetAttribute("Ragdoll", true)

			local TorsoRightArmAttachment = Instance.new("Attachment")
			TorsoRightArmAttachment.Parent = Torso
			TorsoRightArmAttachment.Name = "TorsoRightArmAttachment"
			TorsoRightArmAttachment.Position = Vector3.new(1,0.5,0)
			TorsoRightArmAttachment.Orientation = Vector3.new(0,0,0)
			TorsoRightArmAttachment:SetAttribute("Ragdoll", true)
			
			local RightArmJoint = script.Default:Clone()
			RightArmJoint.Parent = Torso
			RightArmJoint.Name = "RightArmJoint"
			RightArmJoint.Attachment0 = TorsoRightArmAttachment
			RightArmJoint.Attachment1 = RightArmAttachment
			RightArmJoint:SetAttribute("Ragdoll", true)
			
			--Left Arm

			local LeftArmAttachment = Instance.new("Attachment")
			LeftArmAttachment.Parent = LeftArm
			LeftArmAttachment.Name = "LeftArmAttachment"
			LeftArmAttachment.Position = Vector3.new(0.5,0.5,0)
			LeftArmAttachment.Orientation = Vector3.new(0,0,0)
			LeftArmAttachment:SetAttribute("Ragdoll", true)

			local TorsoLeftArmAttachment = Instance.new("Attachment")
			TorsoLeftArmAttachment.Parent = Torso
			TorsoLeftArmAttachment.Name = "TorsoLeftArmAttachment"
			TorsoLeftArmAttachment.Position = Vector3.new(-1,0.5,0)
			TorsoLeftArmAttachment.Orientation = Vector3.new(0,0,0)
			TorsoLeftArmAttachment:SetAttribute("Ragdoll", true)
			
			local LeftArmJoint = script.Default:Clone()
			LeftArmJoint.Parent = Torso
			LeftArmJoint.Name = "LeftArmJoint"
			LeftArmJoint.Attachment0 = TorsoLeftArmAttachment
			LeftArmJoint.Attachment1 = LeftArmAttachment
			LeftArmJoint:SetAttribute("Ragdoll", true)
			
			--Right Leg
			
			local RightLegAttachment = Instance.new("Attachment")
			RightLegAttachment.Parent = RightLeg
			RightLegAttachment.Name = "RightLegAttachment"
			RightLegAttachment.Position = Vector3.new(0,1,0)
			RightLegAttachment.Orientation = Vector3.new(0,0,-90)
			RightLegAttachment:SetAttribute("Ragdoll", true)
			
			local TorsoRightLegAttachment = Instance.new("Attachment")
			TorsoRightLegAttachment.Parent = Torso
			TorsoRightLegAttachment.Name = "TorsoRightLegAttachment"
			TorsoRightLegAttachment.Position = Vector3.new(-0.5,-1,0)
			TorsoRightLegAttachment.Orientation = Vector3.new(0,0,-90)
			TorsoRightLegAttachment:SetAttribute("Ragdoll", true)
			
			local RightLegJoint = script.Default:Clone()
			RightLegJoint.Parent = Torso
			RightLegJoint.Name = "RightLegJoint"
			RightLegJoint.Attachment0 = RightLegAttachment
			RightLegJoint.Attachment1 = TorsoRightLegAttachment
			RightLegJoint:SetAttribute("Ragdoll", true)
			
			--Left Leg

			local LeftLegAttachment = Instance.new("Attachment")
			LeftLegAttachment.Parent = LeftLeg
			LeftLegAttachment.Name = "LeftLegAttachment"
			LeftLegAttachment.Position = Vector3.new(0,1,0)
			LeftLegAttachment.Orientation = Vector3.new(0,0,-90)
			LeftLegAttachment:SetAttribute("Ragdoll", true)

			local TorsoLeftLegAttachment = Instance.new("Attachment")
			TorsoLeftLegAttachment.Parent = Torso
			TorsoLeftLegAttachment.Name = "TorsoLeftLegAttachment"
			TorsoLeftLegAttachment.Position = Vector3.new(0.5,-1,0)
			TorsoLeftLegAttachment.Orientation = Vector3.new(0,0,-90)
			TorsoLeftLegAttachment:SetAttribute("Ragdoll", true)

			local LeftLegJoint = script.Default:Clone()
			LeftLegJoint.Parent = Torso
			LeftLegJoint.Name = "LeftLegJoint"
			LeftLegJoint.Attachment0 = LeftLegAttachment
			LeftLegJoint.Attachment1 = TorsoLeftLegAttachment
			LeftArmJoint:SetAttribute("Ragdoll", true)
		end
		
		HumanoidRootPart.CanCollide = false
		
		for _,v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "LowerTorso" and v.Name ~= "UpperTorso" then
				local NC = Instance.new("NoCollisionConstraint")
				NC.Parent = Torso
				NC.Name = v.Name
				NC.Part0 = v
				NC.Part1 = Torso
				NC:SetAttribute("Ragdoll", true)
			end
		end
	else
		local Head = Character:FindFirstChild("Head")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		local UpperTorso = Character:FindFirstChild("UpperTorso")
		local LowerTorso = Character:FindFirstChild("LowerTorso")
		local RightUpperLeg = Character:FindFirstChild("RightUpperLeg")
		local LeftUpperLeg = Character:FindFirstChild("LeftUpperLeg")
		local RightLowerLeg = Character:FindFirstChild("RightLowerLeg")
		local LeftLowerLeg = Character:FindFirstChild("LeftLowerLeg")
		local RightFoot = Character:FindFirstChild("RightFoot")
		local LeftFoot = Character:FindFirstChild("LeftFoot")
		local RightUpperArm = Character:FindFirstChild("RightUpperArm")
		local LeftUpperArm = Character:FindFirstChild("LeftUpperArm")
		local RightLowerArm = Character:FindFirstChild("RightLowerArm")
		local LeftLowerArm = Character:FindFirstChild("LeftLowerArm")
		local RightHand = Character:FindFirstChild("RightHand")
		local LeftHand = Character:FindFirstChild("LeftHand")
		
		local NeckJoint = script.Neck:Clone()
		NeckJoint.Parent = LowerTorso
		NeckJoint.Name = "NeckJoint"
		NeckJoint.Attachment0 = Head.NeckRigAttachment
		NeckJoint.Attachment1 = UpperTorso.NeckRigAttachment
		NeckJoint:SetAttribute("Ragdoll", true)
		
		local WaistJoint = script.Waist:Clone()
		WaistJoint.Parent = LowerTorso
		WaistJoint.Name = "WaistJoint"
		WaistJoint.Attachment0 = LowerTorso.WaistRigAttachment
		WaistJoint.Attachment1 = UpperTorso.WaistRigAttachment
		WaistJoint:SetAttribute("Ragdoll", true)
		
		local RightHipJoint = script.Hip:Clone()
		RightHipJoint.Parent = LowerTorso
		RightHipJoint.Name = "RightHipJoint"
		RightHipJoint.Attachment0 = LowerTorso.RightHipRigAttachment
		RightHipJoint.Attachment1 = RightUpperLeg.RightHipRigAttachment
		RightHipJoint:SetAttribute("Ragdoll", true)
		
		local LeftHipJoint = script.Hip:Clone()
		LeftHipJoint.Parent = LowerTorso
		LeftHipJoint.Name = "LeftHipJoint"
		LeftHipJoint.Attachment0 = LowerTorso.LeftHipRigAttachment
		LeftHipJoint.Attachment1 = LeftUpperLeg.LeftHipRigAttachment
		LeftHipJoint:SetAttribute("Ragdoll", true)
		
		local RightKneeJoint = script.Knee:Clone()
		RightKneeJoint.Parent = LowerTorso
		RightKneeJoint.Name = "RightKneeJoint"
		RightKneeJoint.Attachment0 = RightUpperLeg.RightKneeRigAttachment
		RightKneeJoint.Attachment1 = RightLowerLeg.RightKneeRigAttachment
		RightKneeJoint:SetAttribute("Ragdoll", true)
		
		local LeftKneeJoint = script.Knee:Clone()
		LeftKneeJoint.Parent = LowerTorso
		LeftKneeJoint.Name = "LeftKneeJoint"
		LeftKneeJoint.Attachment0 = LeftUpperLeg.LeftKneeRigAttachment
		LeftKneeJoint.Attachment1 = LeftLowerLeg.LeftKneeRigAttachment
		LeftKneeJoint:SetAttribute("Ragdoll", true)
		
		local RightAnkleJoint = script.Ankle:Clone()
		RightAnkleJoint.Parent = LowerTorso
		RightAnkleJoint.Name = "RightAnkleJoint"
		RightAnkleJoint.Attachment0 = RightLowerLeg.RightAnkleRigAttachment
		RightAnkleJoint.Attachment1 = RightFoot.RightAnkleRigAttachment
		RightAnkleJoint:SetAttribute("Ragdoll", true)
		
		local LeftAnkleJoint = script.Ankle:Clone()
		LeftAnkleJoint.Parent = LowerTorso
		LeftAnkleJoint.Name = "LeftAnkleJoint"
		LeftAnkleJoint.Attachment0 = LeftLowerLeg.LeftAnkleRigAttachment
		LeftAnkleJoint.Attachment1 = LeftFoot.LeftAnkleRigAttachment
		LeftAnkleJoint:SetAttribute("Ragdoll", true)
		
		local RightShoulderJoint = script.Shoulder:Clone()
		RightShoulderJoint.Parent = LowerTorso
		RightShoulderJoint.Name = "RightShoulderJoint"
		RightShoulderJoint.Attachment0 = UpperTorso.RightShoulderRigAttachment
		RightShoulderJoint.Attachment1 = RightUpperArm.RightShoulderRigAttachment
		RightShoulderJoint:SetAttribute("Ragdoll", true)
		
		local LeftShoulderJoint = script.Shoulder:Clone()
		LeftShoulderJoint.Parent = LowerTorso
		LeftShoulderJoint.Name = "LeftShoulderJoint"
		LeftShoulderJoint.Attachment0 = UpperTorso.LeftShoulderRigAttachment
		LeftShoulderJoint.Attachment1 = LeftUpperArm.LeftShoulderRigAttachment
		LeftShoulderJoint:SetAttribute("Ragdoll", true)
		
		local RightElbowJoint = script.Elbow:Clone()
		RightElbowJoint.Parent = LowerTorso
		RightElbowJoint.Name = "RightElbowJoint"
		RightElbowJoint.Attachment0 = RightUpperArm.RightElbowRigAttachment
		RightElbowJoint.Attachment1 = RightLowerArm.RightElbowRigAttachment
		RightElbowJoint:SetAttribute("Ragdoll", true)

		local LeftElbowJoint = script.Elbow:Clone()
		LeftElbowJoint.Parent = LowerTorso
		LeftElbowJoint.Name = "LeftElbowJoint"
		LeftElbowJoint.Attachment0 = LeftUpperArm.LeftElbowRigAttachment
		LeftElbowJoint.Attachment1 = LeftLowerArm.LeftElbowRigAttachment
		LeftElbowJoint:SetAttribute("Ragdoll", true)
		
		local RightWristJoint = script.Wrist:Clone()
		RightWristJoint.Parent = LowerTorso
		RightWristJoint.Name = "RightWristJoint"
		RightWristJoint.Attachment0 = RightLowerArm.RightWristRigAttachment
		RightWristJoint.Attachment1 = RightHand.RightWristRigAttachment
		RightWristJoint:SetAttribute("Ragdoll", true)

		local LeftWristJoint = script.Wrist:Clone()
		LeftWristJoint.Parent = LowerTorso
		LeftWristJoint.Name = "LeftWristJoint"
		LeftWristJoint.Attachment0 = LeftLowerArm.LeftWristRigAttachment
		LeftWristJoint.Attachment1 = LeftHand.LeftWristRigAttachment
		LeftWristJoint:SetAttribute("Ragdoll", true)
		
		HumanoidRootPart.CanCollide = false
		
		for _,v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "LowerTorso" and v.Name ~= "UpperTorso" then
				local NC1 = Instance.new("NoCollisionConstraint")
				NC1.Parent = LowerTorso
				NC1.Name = v.Name
				NC1.Part0 = v
				NC1.Part1 = LimbTree.GetParent(v.Name, Character)
				NC1:SetAttribute("Ragdoll", true)
				
				local NC2 = Instance.new("NoCollisionConstraint")
				NC2.Parent = LowerTorso
				NC2.Name = v.Name
				NC2.Part0 = v
				NC2.Part1 = LowerTorso
				NC2:SetAttribute("Ragdoll", true)
				
				local NC3 = Instance.new("NoCollisionConstraint")
				NC3.Parent = LowerTorso
				NC3.Name = v.Name
				NC3.Part0 = v
				NC3.Part1 = UpperTorso
				NC3:SetAttribute("Ragdoll", true)
			end
		end
	end
	
	for _,v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") and v.Name ~= "Root" and v.Name ~= "RootJoint" then
			v.Enabled = false
		end
	end
end

function Ragdoll.UnRagdollCharacter(Character : Model)
	local Player = Players:GetPlayerFromCharacter(Character)

	if Player then
		PlayerEvents:WaitForChild("Ragdoll"):FireClient(Player, false)
	end
	
	local Humanoid = Character:FindFirstChild("Humanoid")
	Humanoid.AutoRotate = true
	
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if HumanoidRootPart then HumanoidRootPart.CanCollide = true end
	
	for _,v in pairs(Character:GetDescendants()) do
		if v:GetAttribute("Ragdoll") then
			v:Destroy()
		end
		
		if v:IsA("Motor6D") then
			v.Enabled = true
		end
	end
end

return Ragdoll
