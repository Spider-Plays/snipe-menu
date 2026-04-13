-- Troll Actions System - Server Side

-- Helper: Execute troll action with admin validation
function ExecuteTrollAction(eventName, clientEvent, localeKey, exploitLocaleKey, targetId, extraData)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales[exploitLocaleKey])
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    if extraData then
        TriggerClientEvent(clientEvent, targetId, extraData, playerId)
    else
        TriggerClientEvent(clientEvent, targetId, playerId)
    end

    SendLogs(playerId, "triggered", Config.Locales[localeKey] .. GetPlayerName(targetId))
end

RegisterServerEvent("snipe-adminmenu:server:drunkPlayer", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.drunk_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:drunkPlayer", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.drunk_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:firePlayer", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.fire_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:fiePlayer", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.fire_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:sendToJailBox", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.send_box_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:sendToJailBox", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.send_box_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:slapSky", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.slap_sky_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:slapSky", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.slap_sky_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:damagePlayerVehicle", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.damage_vehicle_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:damagevehicle", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.damage_vehicle_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:peePlayer", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.pee_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:peePlayer", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.pee_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:poopPlayer", function(targetId)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.poop_player_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:poopPlayer", targetId, playerId)
        SendLogs(playerId, "triggered", Config.Locales.poop_player_used .. GetPlayerName(targetId))
    end
end)

RegisterServerEvent("snipe-adminmenu:server:playSound", function(targetId, soundName)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.play_sound_exploit)
        return
    end

    if onlineAdmins[playerId] then
        TriggerClientEvent("snipe-adminmenu:client:playSound", targetId, soundName, playerId)
        SendLogs(playerId, "triggered", Config.Locales.play_sound_player_used .. GetPlayerName(targetId) .. " to play sound " .. soundName)
    end
end)

CreateCallback("snipe-adminmenu:server:isAdmin", function(source, callback, targetId)
    callback(onlineAdmins[targetId])
end)
