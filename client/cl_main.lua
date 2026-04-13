hasAdminPerms = false
isGod = false
userAccesses = nil
userRole = ""
godMode = false
isInvisible = false
local superJumpEnabled = false
enabledButtons = {}
isTerminal = "no"
isDebug = "no"
toggleDev = false
adminTagEnabledList = {}

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerLoaded)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerLoaded, function()
    TriggerServerEvent("sp-adminmenu:server:playerLoaded")
    
    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getTables", function(result)
        p:resolve(result)
    end)
    
    PropTable = Citizen.Await(p)
    isSpawned = true
    
    local tagPromise = promise.new()
    TriggerCallback("sp-adminmenu:server:getEnabledAdminTags", function(result)
        tagPromise:resolve(result)
    end)
    
    adminTagEnabledList = Citizen.Await(tagPromise)
    
    if not Config.AdminDuty then
        local permPromise = promise.new()
        TriggerCallback("sp-adminmenu:server:getAdminPerms", function(result)
            permPromise:resolve(result)
        end)
        
        local perms = Citizen.Await(permPromise)
        hasAdminPerms = perms[1]
        userAccesses = perms[2]
        userRole = perms[3] or "God"
        isGod = perms[4]
        
        TriggerEvent("sp-adminmenu:client:addkeymapping", hasAdminPerms)
    end
end)

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerUnload)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerUnload, function()
    isSpawned = false
    
    if PropTable then
        for _, propData in pairs(PropTable) do
            DeleteEntity(propData.obj)
            propData.obj = nil
        end
    end
    
    enabledButtons = {}
    
    if toggleDev then
        TriggerEvent("sp-adminmenu:client:toggleDev")
    end
    
    toggleDev = false
    godMode = false
    isInvisible = false
    superJumpEnabled = false
    blipThread = false
end)

RegisterNetEvent("sp-adminmenu:client:resetPermissions", function()
    if Config.AdminDuty and not hasAdminPerms then
        return
    end
    
    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getAdminPerms", function(result)
        p:resolve(result)
    end)
    
    local perms = Citizen.Await(p)
    hasAdminPerms = perms[1]
    userAccesses = perms[2]
    userRole = perms[3] or "God"
    isGod = perms[4]
    
    TriggerEvent("sp-adminmenu:client:addkeymapping", hasAdminPerms)
end)

adminMenuOpen = false
hasFocus = false
local focusToggleCount = 0

function StartFocusThread()
    focusToggleCount = focusToggleCount + 1
    
    CreateThread(function()
        while adminMenuOpen and not hasFocus do
            Wait(0)
            
            local nuiFocused = IsNuiFocused()
            
            if IsControlJustPressed(0, 19) then
                Wait(100)
                SetNuiFocus(not nuiFocused, not nuiFocused)
                hasFocus = not nuiFocused
            end
        end
    end)
end

function OpenAdminMenu()
    if hasAdminPerms then
        local p = promise.new()
        TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
            p:resolve(result)
        end, userAccesses)
        
        panelsToDisplay = Citizen.Await(p)
        
        SendNUIMessage({
            action = "openMenu",
            data = {
                isGod = isGod,
                userRole = userRole,
                panelsToDisplay = panelsToDisplay,
                clickedPanels = enabledButtons,
                isTerminal = isTerminal,
                isDebug = isDebug,
                isESX = Config.Framework == "esx",
                customPanels = CustomPanels
            }
        })
        
        SetNuiFocus(true, true)
        hasFocus = true
        adminMenuOpen = true
    end
end

placeFocus = false

RegisterNUICallback("toggleFocus", function(data, cb)
    if Config.AllowMovementWhileInMenu then
        Wait(500)
        
        if adminMenuOpen then
            StartFocusThread()
        end
        
        if isSelecting then
            StartFocusThread()
        end
        
        if IsNuiFocused() then
            if adminMenuOpen or isSelecting then
                SetNuiFocus(false, false)
                
                if isSelecting then
                    placeFocus = false
                else
                    hasFocus = false
                end
            end
        end
    end
    
    cb("ok")
end)

RegisterNUICallback("closeMenu", function(data, cb)
    SetNuiFocus(false, false)
    adminMenuOpen = false
    hasFocus = false
    cb("ok")
end)

function GodModethread()
    godMode = not godMode
    local lastVehicle = nil
    
    if godMode then
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.god_mode_used)
    end
    
    if godMode then
        CreateThread(function()
            while godMode do
                local playerPed = PlayerPedId()
                
                SetEntityCanBeDamaged(playerPed, false)
                SetPlayerInvincible(PlayerId(), true)
                SetEntityProofs(playerPed, true, true, true, true, true, true, true, true)
                
                if IsPedInAnyVehicle(playerPed, false) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    lastVehicle = vehicle
                    
                    SetEntityCanBeDamaged(vehicle, false)
                    SetEntityInvincible(vehicle, true)
                    SetEntityProofs(vehicle, true, true, true, true, true, true, true, true)
                    SetEntityDecalsDisabled(vehicle, true)
                    SetVehicleCanBeVisiblyDamaged(vehicle, false)
                end
                
                Citizen.Wait(0)
            end
            
            SetEntityCanBeDamaged(lastVehicle, true)
            SetEntityInvincible(lastVehicle, false)
            SetEntityProofs(lastVehicle, false, false, false, false, false, false, false, false)
            SetEntityDecalsDisabled(lastVehicle, false)
            SetVehicleCanBeVisiblyDamaged(lastVehicle, true)
        end)
    else
        local playerPed = PlayerPedId()
        
        SetEntityCanBeDamaged(playerPed, true)
        SetPlayerInvincible(PlayerId(), false)
        SetEntityProofs(playerPed, false, false, false, false, false, false, false, false)
        
        if lastVehicle ~= nil then
            SetEntityCanBeDamaged(lastVehicle, true)
            SetEntityInvincible(lastVehicle, false)
            SetEntityProofs(lastVehicle, false, false, false, false, false, false, false, false)
        end
    end
end

function ToggleSuperJump()
    superJumpEnabled = not superJumpEnabled
    
    if superJumpEnabled then
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.super_jump_used)
    end
    
    if superJumpEnabled then
        CreateThread(function()
            while superJumpEnabled do
                SetSuperJumpThisFrame(PlayerId())
                Citizen.Wait(0)
            end
        end)
    end
end

local noclipEnabled = false

RegisterNUICallback("fixvehicle", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("sp-adminmenu:client:FixVehicle")
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.fix_vehicle_used)
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.fix_vehicle_exploit)
    end
end)

RegisterNUICallback("godmode", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        cb("ok")
        GodModethread()
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.god_mode_exploit)
    end
end)

RegisterNUICallback("noclip", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        cb("ok")
        ToggleNoClip(not IsNoClipping)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.noclip_exploit)
    end
end)

RegisterNetEvent("sp-adminmenu:client:toggleAdminTag", function(serverId, enabled, isFromServer)
    if isFromServer then
        adminTagEnabledList[serverId] = enabled
        return
    end
    
    local p = promise.new()
    TriggerCallback("snipe-adminmenu:server:isAdmin", function(result)
        p:resolve(result)
    end, serverId)
    
    local isAdmin = Citizen.Await(p)
    
    if isAdmin then
        if enabled then
            adminTagEnabledList[serverId] = enabled
        else
            adminTagEnabledList[serverId] = nil
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.admintag_exploit)
    end
end)

local adminTagEnabled = false

RegisterNUICallback("admintag", function(data, cb)
    enabledButtons = data.panelsClicked
    adminTagEnabled = not adminTagEnabled
    
    if hasAdminPerms then
        cb("ok")
        TriggerServerEvent("sp-adminmenu:server:toggleAdminTag", adminTagEnabled)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.admintag_exploit)
    end
end)

RegisterNUICallback("invisible", function(data, cb)
    enabledButtons = data.panelsClicked
    isInvisible = not isInvisible
    
    if isInvisible then
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.invisible_used)
    end
    
    if hasAdminPerms then
        cb("ok")
        SetEntityVisible(PlayerPedId(), not isInvisible, 0)
        
        CreateThread(function()
            while isInvisible do
                SetEntityLocallyVisible(PlayerPedId())
                Citizen.Wait(0)
            end
        end)
        
        SetEntityAlpha(PlayerPedId(), isInvisible and 100 or 255, false)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.invisible_exploit)
    end
end)

RegisterNUICallback("teleportmarker", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("sp-adminmenu:client:teleportMarker")
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.teleport_marker_used)
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.teleport_exploit)
    end
end)

RegisterNUICallback("superjump", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        cb("ok")
        ToggleSuperJump()
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.super_jump_exploit)
    end
end)

local minimapEnabled = false

function ToggleMinimap()
    CreateThread(function()
        minimapEnabled = not minimapEnabled
        
        while minimapEnabled do
            DisplayRadar(true)
            Citizen.Wait(0)
        end
    end)
end

RegisterNUICallback("toggleminimap", function(data, cb)
    enabledButtons = data.panelsClicked
    
    if hasAdminPerms then
        cb("ok")
        ToggleMinimap()
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.super_jump_exploit)
    end
end)

RegisterNUICallback("removeStress", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("sp-adminmenu:server:removeStress", data.selectedPlayer.id)
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.stress_exploit)
    end
end)

function FormatCoordinate(number, decimals)
    return tonumber(string.format("%." .. (decimals or 0) .. "f", number))
end

RegisterNUICallback("getVector2", function(data, cb)
    if hasAdminPerms then
        local coords = GetEntityCoords(PlayerPedId())
        cb(string.format("vector2(%s, %s)", 
            FormatCoordinate(coords.x, 3), 
            FormatCoordinate(coords.y, 3)))
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.get_vector3_exploit)
    end
end)

RegisterNUICallback("getVector3", function(data, cb)
    if hasAdminPerms then
        local coords = GetEntityCoords(PlayerPedId())
        cb(string.format("vector3(%s, %s, %s)", 
            FormatCoordinate(coords.x, 3), 
            FormatCoordinate(coords.y, 3), 
            FormatCoordinate(coords.z, 3)))
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.get_vector3_exploit)
    end
end)

RegisterNUICallback("getVector4", function(data, cb)
    if hasAdminPerms then
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        
        cb(string.format("vector4(%s, %s, %s, %s)", 
            FormatCoordinate(coords.x, 3), 
            FormatCoordinate(coords.y, 3), 
            FormatCoordinate(coords.z, 3), 
            FormatCoordinate(heading, 3)))
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.get_vector4_exploit)
    end
end)

RegisterNUICallback("getJson", function(data, cb)
    if hasAdminPerms then
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        
        cb(string.format("{\"x\":%s,\"y\":%s,\"z\":%s,\"w\":%s}", 
            FormatCoordinate(coords.x, 3), 
            FormatCoordinate(coords.y, 3), 
            FormatCoordinate(coords.z, 3), 
            FormatCoordinate(heading, 3)))
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.get_json_exploit)
    end
end)

function RemoveInvisibleEffect()
    isInvisible = false
    
    for index, buttonName in pairs(enabledButtons) do
        if buttonName == "Invisible" then
            table.remove(enabledButtons, index)
        end
    end
end

RegisterNetEvent("sp-adminmenu:client:invisibleEffect", function()
    if hasAdminPerms then
        isInvisible = not isInvisible
        
        if isInvisible then
            enabledButtons[#enabledButtons + 1] = "Invisible"
            TriggerServerEvent("sp-adminmenu:server:sendLogs", "triggered", Config.Locales.invisible_used)
        else
            RemoveInvisibleEffect()
        end
        
        SetEntityVisible(PlayerPedId(), not isInvisible, 0)
        
        CreateThread(function()
            while isInvisible do
                SetEntityLocallyVisible(PlayerPedId())
                Citizen.Wait(0)
            end
        end)
        
        SetEntityAlpha(PlayerPedId(), isInvisible and 100 or 255, false)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.invisible_exploit)
    end
end)

RegisterNetEvent("sp-adminmenu:client:godMode", function()
    if hasAdminPerms then
        GodModethread()
        
        if godMode then
            enabledButtons[#enabledButtons + 1] = "God Mode"
            ShowNotification(Config.Locales.god_mode_enabled, "success")
        else
            for index = 1, #enabledButtons do
                if enabledButtons[index] == "God Mode" then
                    table.remove(enabledButtons, index)
                    break
                end
            end
            
            ShowNotification(Config.Locales.god_mode_disabled, "error")
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.god_mode_exploit)
    end
end)
