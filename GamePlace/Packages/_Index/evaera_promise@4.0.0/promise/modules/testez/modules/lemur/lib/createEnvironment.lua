local createSettings = import("./createSettings")
local functions = import("./functions")
local libs = import("./libs")
local taskFunctions = import("./taskFunctions")
local types = import("./types")
local Enum = import("./Enum")
local Instance = import("./Instance")

local baseEnvironment = {}

for key, value in _G do
	baseEnvironment[key] = value
end

for key, value in types do
	baseEnvironment[key] = value
end

for key, lib in libs do
	baseEnvironment[key] = lib
end

baseEnvironment.Instance = Instance
baseEnvironment.Enum = Enum
baseEnvironment.__LEMUR__ = true

--[[
	Create a new script environment, suitable for use with the given habitat.
]]
local function createEnvironment(habitat)
	local environment = {}

	for key, value in baseEnvironment do
		environment[key] = value
	end

	for key, fn in functions do
		environment[key] = fn
	end

	for key, fnCreator in taskFunctions do
		environment[key] = fnCreator(habitat.taskScheduler)
	end

	environment.settings = createSettings(habitat.settings)

	environment.require = function(path)
		return habitat:require(path)
	end

	environment.game = habitat.game

	return environment
end

return createEnvironment
