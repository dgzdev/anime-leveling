local LimbTree = {
	["LowerTorso"]                = "HumanoidRootPart",
		["UpperTorso"]            = "LowerTorso",
			["Head"]              = "UpperTorso",
			["RightUpperArm"]     = "UpperTorso",
				["RightLowerArm"] = "RightUpperArm",
					["RightHand"] = "RightLowerArm",
			["LeftUpperArm"]      = "UpperTorso",
				["LeftLowerArm"]  = "RightUpperArm",
					["LeftHand"]  = "RightLowerArm",
			["RightUpperLeg"]     = "LowerTorso",
				["RightLowerLeg"] = "RightUpperLeg",
					["RightFoot"] = "RightLowerLeg",
			["LeftUpperLeg"]      = "LowerTorso",
				["LeftLowerLeg"]  = "LeftUpperLeg",
					["LeftFoot"]  = "LeftLowerLeg",
}	

function LimbTree.GetParent(Limb, Character)
	local Search = Character:FindFirstChild(LimbTree[Limb])
	if Search then return Search end
	return nil
end

return LimbTree
