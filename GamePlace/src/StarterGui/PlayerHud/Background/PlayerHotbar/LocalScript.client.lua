local childs = script.Parent:GetChildren()
for i,v in ipairs(childs) do
	v:GetAttributeChangedSignal("Active"):Connect(function(...: any) 
		local value = v:GetAttribute("Active")
		if value then
			if v:FindFirstChildOfClass("ImageLabel") then
				v:FindFirstChildOfClass("ImageLabel").ImageTransparency = 0
			end
			v.SlotImage.ImageTransparency = 0
			v.ImageColor3 = Color3.new(1,1,1)
		else
			if v:FindFirstChildOfClass("ImageLabel") then
				v:FindFirstChildOfClass("ImageLabel").ImageTransparency = 0.7
			end
			v.SlotImage.ImageTransparency = 0.7
			v.ImageColor3 = Color3.new(.5,.5,.5)
		end
	end)
end