-- Main Admin System - Server Side

onlineAdmins = {}
sendBackCoords = {}
devMode = {}
enabledAdminTagsList = {}
adminRoleLabel = {}

CreateCallback("snipe-menu:server:getPlayerList", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:getPlayerList")
        DropPlayer(source, "Exploit detected")
        return
    end

    callback(playersTable)
end)

RegisterServerEvent("snipe-menu:server:toggleDev", function(enabled)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: snipe-menu:server:toggleDev")
        DropPlayer(playerId, "Exploit detected")
        return
    end

    devMode[playerId] = enabled
end)

CreateCallback("snipe-menu:server:getEnabledAdminTags", function(source, callback)
    callback(enabledAdminTagsList)
end)

RegisterServerEvent("snipe-menu:server:toggleAdminTag", function(enabled)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.admintag_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    if enabled then
        enabledAdminTagsList[playerId] = adminRoleLabel[playerId]
    else
        enabledAdminTagsList[playerId] = nil
    end

    local tagLabel = enabled and adminRoleLabel[playerId] or nil
    TriggerClientEvent("snipe-menu:client:toggleAdminTag", -1, playerId, tagLabel)
end)

RegisterServerEvent("snipe-menu:server:freezeplayer", function(targetId, isUnfreeze)
    local playerId = source

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.freeze_exploit_event)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    if not isUnfreeze then
        SendLogs(playerId, "triggered", Config.Locales.freeze_player_used .. GetPlayerName(targetId))
    end

    FreezeEntityPosition(GetPlayerPed(targetId), not isUnfreeze)
end)

RegisterServerEvent("snipe-menu:server:teleporttoplayer", function(targetId)
    local playerId = source

    if playerId == targetId then
        return
    end

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.teleport_player_event_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    SendLogs(playerId, "triggered", Config.Locales.teleport_player_used .. GetPlayerName(targetId))
    TriggerClientEvent("snipe-menu:client:teleporttoplayer", playerId, targetCoords)
end)

RegisterServerEvent("snipe-menu:server:bringPlayer", function(targetId, adminCoords)
    local playerId = source

    if playerId == targetId then
        return
    end

    sendBackCoords[targetId] = GetEntityCoords(GetPlayerPed(targetId))

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.bring_player_event_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    SendLogs(playerId, "triggered", Config.Locales.bring_player_used .. GetPlayerName(targetId))
    TriggerClientEvent("snipe-menu:client:bringPlayer", targetId, playerId, adminCoords)
end)

RegisterServerEvent("snipe-menu:server:sendBackPlayer", function(targetId)
    local playerId = source

    if playerId == targetId then
        return
    end

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.bring_player_event_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    if sendBackCoords[targetId] then
        TriggerClientEvent("snipe-menu:client:sendBackPlayer", targetId, playerId, sendBackCoords[targetId])
        sendBackCoords[targetId] = nil
    else
        ShowNotification(playerId, Config.Locales.no_player_coords, "error")
    end
end)

RegisterServerEvent("snipe-menu:server:openinventory", function(targetId)
    local playerId = source

    if playerId == targetId then
        ShowNotification(playerId, "Cannot open your own inventory", "error")
        return
    end

    if playerId == 0 then
        SendLogs(playerId, "triggered", Config.Locales.inventory_open_event_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    SendLogs(playerId, "triggered", Config.Locales.inventory_open_used .. GetPlayerName(targetId))
    TriggerClientEvent("snipe-menu:client:openinventory", playerId, targetId)
end)

CreateCallback("snipe-menu:server:getAdminPerms", function(source, callback)
    if invalid then
        print("^1[Invalid Core] ^0You have You have not selected the right Config.Core in framework.lua ^0!")
        return
    end

    if wrongName then
        print("^1[Resource Rename] ^0You have renamed the resource. No permissions will work. Please rename it back to ^snipe-menu^0!")
        return
    end

    local permissions = HasPerms(source)
    if not permissions then
        return
    end

    onlineAdmins[source] = permissions[1]

    if type(permissions[2]) == "string" then
        permissions[3] = Config.GodRoles[permissions[2]]
        adminRoleLabel[source] = permissions[3]
        permissions[4] = (permissions[2] == "god")
        callback(permissions)
    elseif type(permissions[2]) == "table" then
        if tableContains(permissions[2], "god") then
            permissions[3] = Config.GodRoles.god
            permissions[4] = true
            adminRoleLabel[source] = permissions[3]
            callback(permissions)
        else
            permissions[3] = Config.GodRoles[permissions[2][1]]
            adminRoleLabel[source] = permissions[3]
            permissions[4] = false
            callback(permissions)
        end
    end
end)
