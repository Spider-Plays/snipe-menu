-- Resources & Player List Client - NUI Callbacks

RegisterNUICallback("getPlayerDataForList", function(data, callback)
    local p = promise.new()

    TriggerCallback("snipe-menu:server:getPlayerDataForList", function(result)
        p:resolve(result)
    end)

    local playerData = Citizen.Await(p)
    callback(playerData)
end)

RegisterNUICallback("playerListActions", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    local action = data.action
    local targetId = tonumber(data.playerId)

    if action == "teleport" then
        TriggerServerEvent("snipe-menu:server:teleporttoplayer", targetId)

    elseif action == "bring" then
        local myCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("snipe-menu:server:bringPlayer", targetId, myCoords)

    elseif action == "spectate" then
        TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        TriggerServerEvent("snipe-menu:server:startSpectating", targetId)

    elseif action == "freeze" then
        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
        local isFrozen = IsEntityPositionFrozen(targetPed)
        TriggerServerEvent("snipe-menu:server:freezeplayer", targetId, isFrozen)

    elseif action == "send_back" then
        TriggerServerEvent("snipe-menu:server:sendBackPlayer", targetId)
    end

    callback("ok")
end)

RegisterNUICallback("getResourceList", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    local p = promise.new()

    TriggerCallback("snipe-menu:server:getResourceList", function(result)
        p:resolve(result)
    end)

    local resourceData = Citizen.Await(p)
    callback(resourceData)
end)

RegisterNUICallback("startResource", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    TriggerServerEvent("snipe-menu:server:startResource", data.name)
    Wait(1000)

    local state = GetResourceState(data.name)
    if state == "started" then
        callback("ok")
    else
        callback("not ok")
    end
end)

RegisterNUICallback("stopResource", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    TriggerServerEvent("snipe-menu:server:stopResource", data.name)
    Wait(1000)

    local state = GetResourceState(data.name)
    if state == "stopped" then
        callback("ok")
    else
        callback("not ok")
    end
end)

RegisterNUICallback("restartResource", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    TriggerServerEvent("snipe-menu:server:restartResource", data.name)
    Wait(1000)

    local state = GetResourceState(data.name)
    if state == "started" then
        callback("ok")
    else
        callback("not ok")
    end
end)
