-- Reports System Client - NUI Callbacks

function OpenReports()
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getReportsForUser", function(result)
        p:resolve(result)
    end)

    local reportData = Citizen.Await(p)

    SendNUIMessage({
        action = "openUserReportMenu",
        data = reportData
    })

    SendNUIMessage({ action = "hideUnreadReport" })
    SetNuiFocus(true, true)
end

RegisterNUICallback("closeReport", function(data, callback)
    SetNuiFocus(false, false)
    callback("ok")
end)

RegisterNUICallback("sendReportMessage", function(data, callback)
    TriggerServerEvent("sp-adminmenu:server:reportSent", data.newMessage)
    Wait(100)

    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getReportsForUser", function(result)
        p:resolve(result)
    end)

    local reportData = Citizen.Await(p)
    callback(reportData)
end)

RegisterNUICallback("getAllUserNameWithReports", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getPlayersWithReports", function(result)
        p:resolve(result)
    end)

    local playersData = Citizen.Await(p)

    SendNUIMessage({ action = "hideUnreadReport" })
    callback(playersData)
end)

RegisterNUICallback("sendMessageFromAdmin", function(data, callback)
    TriggerServerEvent("sp-adminmenu:server:adminReply", data.message, data.playerId)
    Wait(100)

    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getUserChats", function(result)
        p:resolve(result)
    end, data.playerId)

    local chatData = Citizen.Await(p)
    callback(chatData)
end)

RegisterNUICallback("getPlayerChats", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getUserChats", function(result)
        p:resolve(result)
    end, data.playerId)

    local chatData = Citizen.Await(p)
    callback(chatData)
end)

RegisterNUICallback("teleportToPlayerReport", function(data, callback)
    local targetId = data.playerId
    local myCoords = GetEntityCoords(PlayerPedId())

    TriggerServerEvent("sp-adminmenu:server:playerTeleportFromReport", myCoords, targetId)
    callback("ok")
end)

RegisterNUICallback("sendBackReport", function(data, callback)
    TriggerServerEvent("sp-adminmenu:server:sendBackPlayer", data.playerId)
    callback("ok")
end)

RegisterNUICallback("spectatePlayerReport", function(data, callback)
    if not hasAdminPerms then return end

    local myServerId = GetPlayerServerId(PlayerId())
    local targetId = tonumber(data.playerId)

    if myServerId == targetId then
        print("You can't spectate yourself")
        callback("ok")
        return
    end

    TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
    TriggerServerEvent("sp-adminmenu:server:startSpectating", targetId)
    callback("ok")
end)

RegisterNUICallback("bringPlayerReport", function(data, callback)
    if hasAdminPerms then
        local targetId = tonumber(data.playerId)
        local myCoords = GetEntityCoords(PlayerPedId())

        TriggerServerEvent("sp-adminmenu:server:bringPlayer", targetId, myCoords)
        callback("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.bring_player_exploit)
    end
end)

RegisterNUICallback("closeTicket", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:closeTicket", function(result)
        p:resolve(result)
    end, data.playerId, data.playerName)

    Citizen.Await(p)
    callback("ok")
end)

RegisterNetEvent("sp-adminmenu:client:showReportUnread", function()
    SendNUIMessage({ action = "showUnreadReport" })
end)

RegisterNetEvent("sp-adminmenu:client:hideReportUnread", function()
    SendNUIMessage({ action = "hideUnreadReport" })
end)
