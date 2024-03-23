local Packages = {}

local CachedPackages = {}

function CachedPackages:GetAlot(parameter: ({
	Type: string,
	Name: string,
	Module: ModuleScript,
}) -> boolean)
	local Found = {}
	for _, M in CachedPackages do
		if parameter(M) == true then
			Found[#Found + 1] = M.Module
		end
	end

	if #Found == 0 then
		return error("No package found with the given parameter")
	end

	return Found
end

function CachedPackages:Get(parameter: ({
	Type: string,
	Name: string,
	Module: ModuleScript,
}) -> boolean)
	for _, M in CachedPackages do
		if parameter(M) == true then
			return M.Module
		end
	end

	return error("No package found with the given parameter")
end

function Packages:StorePackage(Module: ModuleScript): nil
	CachedPackages[#CachedPackages + 1] = {
		Module = require(Module),
		Name = Module.Name,
		Type = Module.Parent.Name,
	}
end

function Packages:GetByName(name: string): any?
	return CachedPackages:Get(function(M)
		return M.Name == name
	end)
end

function Packages:GetByType(type: string): { [any]: any }?
	return CachedPackages:GetAlot(function(M)
		return M.Type == type
	end)
end

function Packages:GetByFunction(func: ({ Name: string, Module: any, Type: string }) -> boolean): any?
	return CachedPackages:Get(func)
end

do
	for _, md: ModuleScript in script:GetDescendants() do
		if md:IsA("ModuleScript") then
			Packages:StorePackage(md)
		end
	end
end

return Packages
