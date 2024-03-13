local names = {
	"typeof",
	"warn",
	"tick",
}

local functions = {}

for _, name in names do
	functions[name] = import("./" .. name)
end

return functions
