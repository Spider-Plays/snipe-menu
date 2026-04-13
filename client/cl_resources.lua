-- Resources & Player List Client - NUI Callbacks

RegisterNUICallback("getPlayerDataForList", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getPlayerDataForList", function(result)
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
        TriggerServerEvent("sp-adminmenu:server:teleporttoplayer", targetId)

    elseif action == "bring" then
        local myCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("sp-adminmenu:server:bringPlayer", targetId, myCoords)

    elseif action == "spectate" then
        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        TriggerServerEvent("sp-adminmenu:server:startSpectating", targetId)

    elseif action == "freeze" then
        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
        local isFrozen = IsEntityPositionFrozen(targetPed)
        TriggerServerEvent("sp-adminmenu:server:freezeplayer", targetId, isFrozen)

    elseif action == "send_back" then
        TriggerServerEvent("sp-adminmenu:server:sendBackPlayer", targetId)
    end

    callback("ok")
end)

RegisterNUICallback("getResourceList", function(data, callback)
    if not hasAdminPerms then
        callback("not ok")
        return
    end

    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getResourceList", function(result)
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

    TriggerServerEvent("sp-adminmenu:server:startResource", data.name)
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

    TriggerServerEvent("sp-adminmenu:server:stopResource", data.name)
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

    TriggerServerEvent("sp-adminmenu:server:restartResource", data.name)
    Wait(1000)

    local state = GetResourceState(data.name)
    if state == "started" then
        callback("ok")
    else
        callback("not ok")
    end
end)
