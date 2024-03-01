local childs = script.Parent:GetChildren()
for i,v in ipairs(childs) do
	v:GetAttributeChangedSignal("Active"):Connect(function(...: any) 
		local value = v:GetAttribute("Active")
		if value then
			v.ImageColor3 = Color3.new(1,1,1)
		else
			v.ImageColor3 = Color3.new(0.5,.5,.5)
		end
	end)
end