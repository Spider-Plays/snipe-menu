-- Weather & Time Management Client - NUI Callbacks

function GetWeatherLabelByHash(weatherHash)
    for _, weather in pairs(Config.Weather) do
        if GetHashKey(weather.name) == weatherHash then
            return weather.label
        end
    end
    return nil
end

RegisterNUICallback("getWeatherList", function(data, callback)
    local weatherList = {}

    for _, weather in pairs(Config.Weather) do
        weatherList[#weatherList + 1] = {
            id = weather.name,
            name = weather.label
        }
    end

    callback(weatherList)
end)

RegisterNUICallback("getCurrentWeather", function(data, callback)
    local currentWeatherHash = GetPrevWeatherTypeHashName()
    local weatherLabel = GetWeatherLabelByHash(currentWeatherHash)
    callback(weatherLabel)
end)

RegisterNUICallback("setWeather", function(data, callback)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Weather changed to " .. data.selectedValue.name)
        SetWeather(data.selectedValue.id)
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.weather_change_exploit)
    end
end)

RegisterNUICallback("setTime", function(data, callback)
    if hasAdminPerms then
        local hour = 0
        local selectedTime = data.selectedTime
        local period = data.selectedPeriod

        if selectedTime == 12 and period == "AM" then
            hour = 0
        elseif selectedTime == 12 and period == "PM" then
            hour = 12
        elseif period == "PM" then
            hour = selectedTime + 12
        else
            hour = selectedTime
        end

        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Time changed to " .. hour)
        SetTime(hour, 0)
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.time_change_exploit)
    end
end)
