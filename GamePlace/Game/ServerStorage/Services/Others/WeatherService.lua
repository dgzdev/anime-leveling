local Workspace = game:GetService("Workspace")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local WeatherService = Knit.CreateService({
	Name = "WeatherService",
	Client = {
		WeatherChanged = Knit.CreateSignal(),
	},
})

local Weathers = {
	"Rain",
	"Clear",
	"Cloudy",
	"Snowy",
}

local WeatherData = {
	Rain = {
		Duration = { 300, 600 },
	},
	Clear = {
		Duration = { 600, 950 },
	},
	Cloudy = {
		Duration = { 200, 350 },
	},
	Snowy = {
		Duration = { 300, 600 },
	},
}

function WeatherService:GetRandomWeather()
	return Weathers[math.random(1, #Weathers)]
end

function WeatherService:GetWeather()
	return Workspace:GetAttribute("Weather")
end

function WeatherService.Client:GetWeather()
	return self.Server:GetWeather()
end

function WeatherService:BindWeatherChange()
	task.spawn(function()
		while true do
			local newWeather = WeatherService:GetRandomWeather()
			local duration = WeatherData[newWeather].Duration
			Workspace:SetAttribute("Weather", newWeather)
			task.wait(math.random(duration[1], duration[2]))
		end
	end)
end

function WeatherService.KnitStart()
	WeatherService:BindWeatherChange()
end

return WeatherService
