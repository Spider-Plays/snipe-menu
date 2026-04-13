local infiniteAmmoEnabled = false

function FormatNumber(number, decimalPlaces)
    local formatted = string.format("%." .. (decimalPlaces or 2) .. "f", number)
    local asNumber = tonumber(formatted)
    
    if asNumber then
        if math.floor(asNumber * 10) == asNumber * 10 then
            return asNumber .. "0"
        end
    end
    
    return asNumber
end

lib.hideTextUI()

function ToggleCoordinatesDisplay()
    local x = 0.4
    local y = 0.025
    
    showCoords = not showCoords
    lib.hideTextUI()
    
    CreateThread(function()
        while showCoords do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local playerHeading = GetEntityHeading(PlayerPedId())
            
            local formattedCoords = {
                x = FormatNumber(playerCoords.x, 2),
                y = FormatNumber(playerCoords.y, 2),
                z = FormatNumber(playerCoords.z, 2)
            }
            
            local formattedHeading = FormatNumber(playerHeading, 2)
            
            Wait(0)
            
            local displayText = {
                string.format("Coords: vector3(%s, %s, %s)  \n", formattedCoords.x, formattedCoords.y, formattedCoords.z),
                string.format("Heading: %s  \n", formattedHeading),
                string.format("Coords: vector4(%s, %s, %s, %s)  \n", formattedCoords.x, formattedCoords.y, formattedCoords.z, formattedHeading),
                "[G] to copy vector4 coords  \n",
                "[E] to copy vector3 coords  \n"
            }
            
            ShowTextUI(table.concat(displayText))
            
            if IsControlJustPressed(0, 47) then
                ShowNotification("Copied to Clipboard", "success")
                SendNUIMessage({
                    action = "copytoclipboard",
                    data = string.format("vector4(%s, %s, %s, %s)", formattedCoords.x, formattedCoords.y, formattedCoords.z, formattedHeading)
                })
            end
            
            if IsControlJustPressed(0, 51) then
                ShowNotification("Copied to Clipboard", "success")
                SendNUIMessage({
                    action = "copytoclipboard",
                    data = string.format("vector3(%s, %s, %s)", formattedCoords.x, formattedCoords.y, formattedCoords.z)
                })
            end
        end
        
        lib.hideTextUI()
    end)
end

RegisterNUICallback("kickPlayer", function(data, cb)
    if hasAdminPerms then
        local reason = data.inputValue
        local targetId = tonumber(data.selectedValue.id)
        
        TriggerServerEvent("snipe-menu:server:kickPlayer", targetId, reason)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.kick_player_exploit_event)
    end
end)

RegisterNUICallback("warnPlayer", function(data, cb)
    if hasAdminPerms then
        local reason = data.inputValue
        local targetId = tonumber(data.selectedValue.id)
        
        TriggerServerEvent("snipe-menu:server:warnPlayer", targetId, reason)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.warn_player_exploit_event)
    end
end)

RegisterNUICallback("sendDmToPlayer", function(data, cb)
    if hasAdminPerms then
        local message = data.inputValue
        local targetId = tonumber(data.selectedValue.id)
        
        TriggerServerEvent("snipe-menu:server:sendDmToPlayer", targetId, message)
        cb("ok")
    end
end)

function ConvertBanTimeToSeconds(banTime, banOption)
    local timeInSeconds = banTime
    
    if banOption == "Minutes" then
        timeInSeconds = banTime * 60
    elseif banOption == "Hours" then
        timeInSeconds = banTime * 60 * 60
    elseif banOption == "Weeks" then
        timeInSeconds = banTime * 60 * 60 * 24 * 7
    elseif banOption == "Months" then
        timeInSeconds = banTime * 60 * 60 * 24 * 30
    elseif banOption == "Year" then
        timeInSeconds = banTime * 60 * 60 * 24 * 365
    end
    
    return timeInSeconds
end

RegisterNUICallback("banPlayer", function(data, cb)
    if hasAdminPerms then
        if data.isPermanent then
            TriggerServerEvent("snipe-menu:server:banPlayer", 
                tonumber(data.selectedPlayer.id), 
                2147483647, 
                data.reason, 
                "Permanent")
            cb("ok")
        else
            if data.banTime ~= nil then
                local banTime = tonumber(data.banTime)
                local banTimeInSeconds = ConvertBanTimeToSeconds(banTime, data.banOpt)
                
                TriggerServerEvent("snipe-menu:server:banPlayer", 
                    tonumber(data.selectedPlayer.id), 
                    banTimeInSeconds, 
                    data.reason, 
                    tonumber(data.banTime) .. " " .. data.banOpt)
            end
            cb("ok")
        end
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.ban_player_exploit)
    end
end)

RegisterNUICallback("getAllPlayersOffline", function(data, cb)
    local p = promise.new()
    
    TriggerCallback("snipe-menu:server:getOfflinePlayers", function(result)
        p:resolve(result)
    end)
    
    local offlinePlayers = Citizen.Await(p)
    cb(offlinePlayers)
end)

RegisterNUICallback("getAllUniquePlayers", function(data, cb)
    local p = promise.new()
    
    TriggerCallback("snipe-menu:server:getAllUniquePlayers", function(result)
        p:resolve(result)
    end)
    
    local uniquePlayers = Citizen.Await(p)
    cb(uniquePlayers)
end)

RegisterNUICallback("wipePlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:wipePlayer", data.selectedPlayer.id)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.wipe_player_exploit)
    end
end)

RegisterNUICallback("banOfflinePlayer", function(data, cb)
    if hasAdminPerms then
        if data.banTime ~= nil then
            if data.isPermanent then
                TriggerServerEvent("snipe-menu:server:banOfflinePlayer", 
                    data.selectedPlayer.id, 
                    2147483647, 
                    data.reason, 
                    "Permanent", 
                    data.selectedPlayer.name)
                cb("ok")
            else
                local banTime = tonumber(data.banTime)
                local banTimeInSeconds = ConvertBanTimeToSeconds(banTime, data.banOpt)
                
                TriggerServerEvent("snipe-menu:server:banOfflinePlayer", 
                    data.selectedPlayer.id, 
                    banTimeInSeconds, 
                    data.reason, 
                    tonumber(data.banTime) .. " " .. data.banOpt, 
                    data.selectedPlayer.name)
                cb("ok")
            end
            cb("ok")
        end
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.ban_player_exploit)
        cb("ok")
    end
end)

RegisterNUICallback("showCoords", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        ToggleCoordinatesDisplay()
        cb("ok")
    end
end)

RegisterNUICallback("infiniteAmmo", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        ToggleInfiniteAmmo()
        cb("ok")
    end
end)

function ToggleInfiniteAmmo()
    infiniteAmmoEnabled = not infiniteAmmoEnabled
    local playerPed = PlayerPedId()
    
    SetPedAmmo(playerPed, GetSelectedPedWeapon(playerPed), 100)
    SetPedInfiniteAmmoClip(playerPed, false)
    
    CreateThread(function()
        if infiniteAmmoEnabled then
            SetPedInfiniteAmmoClip(playerPed, true)
        end
        
        while infiniteAmmoEnabled do
            Wait(0)
            local ped = PlayerPedId()
            SetPedAmmo(ped, GetSelectedPedWeapon(ped), 100)
        end
    end)
end

RegisterNUICallback("bringPlayer", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local myCoords = GetEntityCoords(PlayerPedId())
        
        TriggerServerEvent("snipe-menu:server:bringPlayer", targetId, myCoords)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.bring_player_exploit)
    end
end)

RegisterNUICallback("sendBackPlayer", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        
        TriggerServerEvent("snipe-menu:server:sendBackPlayer", targetId)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.bring_player_exploit)
    end
end)

RegisterNUICallback("clearInventory", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        
        TriggerServerEvent("snipe-menu:server:clearInventory", targetId)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.clear_inventory_exploit)
    end
end)

RegisterNUICallback("clearVehicles", function(data, cb)
    if hasAdminPerms then
        local radius = tonumber(data.radius) + 0.0
        local coords = GetEntityCoords(PlayerPedId())
        
        clearArea(radius, "vehicle")
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.clear_vehicles_exploit)
    end
end)

RegisterNUICallback("clearPeds", function(data, cb)
    if hasAdminPerms then
        local radius = tonumber(data.radius) + 0.0
        local coords = GetEntityCoords(PlayerPedId())
        
        clearArea(radius, "ped")
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.clear_peds_exploit)
    end
end)

RegisterNUICallback("clearObjects", function(data, cb)
    if hasAdminPerms then
        local radius = tonumber(data.radius) + 0.0
        local coords = GetEntityCoords(PlayerPedId())
        
        clearArea(radius, "object")
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.clear_object_exploit)
    end
end)

RegisterNUICallback("getRoles", function(data, cb)
    cb(Config.AdminRoles)
end)

RegisterNUICallback("getBannedPlayers", function(data, cb)
    local p = promise.new()
    
    TriggerCallback("snipe-menu:server:getBannedPlayers", function(result)
        p:resolve(result)
    end)
    
    local bannedPlayers = Citizen.Await(p)
    cb(bannedPlayers)
end)

RegisterNUICallback("unbanPlayer", function(data, cb)
    if hasAdminPerms then
        local bannedId = data.selectedPlayer.id
        
        TriggerServerEvent("snipe-menu:server:unbanPlayer", bannedId, data.selectedPlayer.name)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.unban_player_exploit)
    end
end)

RegisterNUICallback("setPedModel", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:changeModel", data.selectedPlayer.id, data.selectedItem.name)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.unban_player_exploit)
    end
end)

RegisterNUICallback("getModels", function(data, cb)
    local models = {}
    
    for modelId, modelName in pairs(pedList) do
        models[#models + 1] = {
            id = modelId,
            name = modelName
        }
    end
    
    cb(models)
end)

function LoadPedModel(modelHash)
    RequestModel(modelHash)
    
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end
end

RegisterNetEvent("snipe-menu:client:changeModel", function(modelName)
    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(modelName)
    
    SetEntityInvincible(playerPed, true)
    LoadPedModel(modelHash)
    SetPlayerModel(PlayerId(), modelHash)
    
    playerPed = PlayerPedId()
    SetPedRandomComponentVariation(playerPed, true)
    SetModelAsNoLongerNeeded(modelHash)
    SetEntityInvincible(playerPed, false)
end)

RegisterNUICallback("revertClothing", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        
        TriggerServerEvent("snipe-menu:server:revertClothing", targetId)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.unban_player_exploit)
    end
end)

RegisterNUICallback("forceLogout", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:forceLogout", data.selectedPlayer.id)
        cb("ok")
    end
end)

RegisterNUICallback("giveOutfits", function(data, cb)
    TriggerServerEvent("snipe-menu:server:giveOutfits", data.selectedPlayer.id)
    cb("ok")
end)
