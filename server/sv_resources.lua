-- Resource Management System - Server Side

-- Helper: Get display name for player
function GetDisplayName(playerId)
    if Config.ShowInGameNamesForNamesAndBlips and playerNames[playerId] then
        return playerNames[playerId]
    end
    return GetPlayerName(playerId)
end

CreateCallback("sp-adminmenu:server:getPlayerDataForList", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:getPlayerDataForList")
        DropPlayer(source, "Exploit detected")
        return
    end

    local result = {
        onlinePlayers = {},
        offlinePlayers = {}
    }

    -- Build online players list
    for playerId, _ in pairs(onlinePlayer) do
        local playerData = {
            id = playerId,
            name = GetDisplayName(playerId),
            licenses = GetPlayerAllLicenses(playerId),
            info = GetPlayerInfo(tonumber(playerId)),
            isAdmin = onlineAdmins[playerId] and true or false
        }
        result.onlinePlayers[#result.onlinePlayers + 1] = playerData
    end

    -- Build offline players list
    for _, droppedPlayer in pairs(droppedPlayers) do
        result.offlinePlayers[#result.offlinePlayers + 1] = {
            id = droppedPlayer.id,
            name = droppedPlayer.name,
            timeOfDisconnect = droppedPlayer.timeOfDisconnect
        }
    end

    callback(result)
end)

CreateCallback("sp-adminmenu:server:getResourceList", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:getResourceList")
        DropPlayer(source, "Exploit detected")
        return
    end

    Wait(100)

    local resources = {}
    local resourceCount = GetNumResources() - 1
    local currentResource = GetCurrentResourceName()

    for i = 0, resourceCount do
        local resourceName = GetResourceByFindIndex(i)

        if resourceName ~= currentResource then
            local isStarted = GetResourceState(resourceName) == "started"

            resources[#resources + 1] = {
                id = i + 1,
                name = resourceName,
                state = isStarted and 1 or 0
            }
        end
    end

    callback({ resources = resources })
end)

RegisterNetEvent("sp-adminmenu:server:startResource", function(resourceName)
    local playerId = source

    if onlineAdmins[playerId] then
        StartResource(resourceName)
        SendLogs(playerId, "triggered", Config.Locales.started_resource .. resourceName)
    else
        SendLogs(playerId, "exploit", Config.Locales.tried_to_start_resource .. resourceName)
    end
end)

RegisterNetEvent("sp-adminmenu:server:stopResource", function(resourceName)
    local playerId = source

    if onlineAdmins[playerId] then
        StopResource(resourceName)
        SendLogs(playerId, "triggered", Config.Locales.stopped_resource .. resourceName)
    else
        SendLogs(playerId, "exploit", "Tried to stop resource" .. resourceName)
    end
end)

RegisterNetEvent("sp-adminmenu:server:restartResource", function(resourceName)
    local playerId = source

    if onlineAdmins[playerId] then
        StopResource(resourceName)
        Wait(100)
        StartResource(resourceName)
        SendLogs(playerId, "triggered", Config.Locales.restarted_resource .. resourceName)
    else
        SendLogs(playerId, "exploit", "Tried to restart resource" .. resourceName)
    end
end)
