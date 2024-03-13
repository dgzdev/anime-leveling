local names = {
	"bit32",
	"math",
	"string",
}

local libs = {}

for _, name in names do
	libs[name] = import("./" .. name)
end

return libs
