local rbxMath = {}

for key, value in math do
	rbxMath[key] = value
end

rbxMath.clamp = function(n, min, max)
	return math.min(max, math.max(min, n))
end

return rbxMath
