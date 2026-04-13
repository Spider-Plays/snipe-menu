-- Open Stashes Client - NUI Callbacks

RegisterNUICallback("getStashes", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getAllStashes", function(result)
        p:resolve(result)
    end)

    local stashes = Citizen.Await(p)
    callback(stashes)
end)

RegisterNUICallback("getAllOwnedVehicles", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getAllOwnedVehicles", function(result)
        p:resolve(result)
    end)

    local vehicles = Citizen.Await(p)
    callback(vehicles)
end)

RegisterNUICallback("openStash", function(data, callback)
    if hasAdminPerms then
        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        OpenStash(data.selectedValue.name, data.inputValue)
        callback("ok")
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", "Opened Stash " .. data.selectedValue.name)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

RegisterNUICallback("openTrunk", function(data, callback)
    if hasAdminPerms then
        local plateId = data.selectedPlayer.id
        local plateName = data.selectedPlayer.name

        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        OpenTrunk(plateId, plateName)
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", "Opened Trunk for plate: " .. plateName)
        callback("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

RegisterNUICallback("openGlovebox", function(data, callback)
    if hasAdminPerms then
        local plateName = data.selectedPlayer.name

        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        OpenGlovebox(plateName)
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", "Opened glovebox for plate: " .. plateName)
        callback("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)
