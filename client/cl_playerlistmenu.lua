-- Player List Menu Client

devMode = false
debugMode = false

-- NUI Callback: Announce message
RegisterNUICallback("announce", function(data, cb)
    if hasAdminPerms then
        local message = data.announcement
        TriggerServerEvent("snipe-menu:server:Announce", message)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.announce_exploit)
    end
end)

-- NUI Callback: Get player list
RegisterNUICallback("getPlayerList", function(data, cb)
    local p = promise.new()
    
    TriggerCallback("snipe-menu:server:getPlayerList", function(result)
        p:resolve(result)
    end)
    
    local players = Citizen.Await(p)
    cb(players)
end)

-- NUI Callback: Give clothes to player
RegisterNUICallback("giveclothes", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:giveClothes", tonumber(data.selectedPlayer.id))
        
        local targetId = tonumber(data.selectedPlayer.id)
        local myServerId = GetPlayerServerId(PlayerId())
        
        if targetId == myServerId then
            TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        end
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.give_clothes_exploit)
    end
end)

-- NUI Callback: Freeze player
RegisterNUICallback("freezeplayer", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
        local isFrozen = IsEntityPositionFrozen(targetPed)
        
        TriggerServerEvent("snipe-menu:server:freezeplayer", targetId, isFrozen)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.freeze_player_exploit)
    end
end)

-- NUI Callback: Revive player
RegisterNUICallback("reviveplayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:reviveplayer", tonumber(data.selectedPlayer.id))
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.revive_player_exploit)
    end
end)

-- NUI Callback: Heal player
RegisterNUICallback("healplayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:healPlayer", tonumber(data.selectedPlayer.id))
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.heal_player_exploit)
    end
end)

-- NUI Callback: Revive all players
RegisterNUICallback("reviveall", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:reviveall")
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.revive_all_exploit)
    end
end)

-- NUI Callback: Revive players in radius
RegisterNUICallback("reviveRadius", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:reviveInRadius")
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.revive_player_exploit)
    end
end)

-- NUI Callback: Teleport to player
RegisterNUICallback("teleporttoplayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-menu:server:teleporttoplayer", tonumber(data.selectedPlayer.id))
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.teleport_player_exploit)
    end
end)

-- NUI Callback: Open player inventory
RegisterNUICallback("openinventory", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
        Wait(100)
        TriggerServerEvent("snipe-menu:server:openinventory", tonumber(data.selectedPlayer.id))
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

-- NUI Callback: Get player info
RegisterNUICallback("getplayerinfo", function(data, cb)
    if hasAdminPerms then
        local p = promise.new()
        
        TriggerCallback("snipe-menu:server:getPlayerInfo", function(result)
            p:resolve(result)
        end, tonumber(data.selectedPlayer.id))
        
        local playerInfo = Citizen.Await(p)
        cb(playerInfo)
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.inventory_open_exploit)
    end
end)

-- NUI Callback: Get jobs list
RegisterNUICallback("getJobs", function(data, cb)
    local jobs = GetJobsWithNameAndLabelAndGrades()
    cb(jobs)
end)

-- NUI Callback: Set player job
RegisterNUICallback("setjob", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local jobName = data.selectedItem.id
        local jobGrade = tonumber(data.selectedItem.grade)
        
        TriggerServerEvent("snipe-menu:server:setjob", targetId, jobName, jobGrade)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.setjob_exploit)
    end
end)

-- NUI Callback: Get gangs list
RegisterNUICallback("getGangs", function(data, cb)
    local gangs = GetGangsWithNameAndLabelAndGrades()
    cb(gangs)
end)

-- NUI Callback: Set player gang
RegisterNUICallback("setGang", function(data, cb)
    if hasAdminPerms then
        local targetId = tonumber(data.selectedPlayer.id)
        local gangName = data.selectedItem.id
        local gangGrade = tonumber(data.selectedItem.grade)
        
        TriggerServerEvent("snipe-menu:server:setGang", targetId, gangName, gangGrade)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.setgang_exploit)
    end
end)

-- NUI Callback: Teleport to coordinates
RegisterNUICallback("teleportcoords", function(data, cb)
    if hasAdminPerms then
        local x = tonumber(data.xcoord)
        local y = tonumber(data.ycoord)
        local z = tonumber(data.zcoord)
        
        SetPedCoordsKeepVehicle(PlayerPedId(), x, y, z)
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", "Teleported to coords: " .. data.xcoord .. ", " .. data.ycoord .. ", " .. data.zcoord)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.setjob_exploit)
    end
end)

-- NUI Callback: Toggle dev mode
RegisterNUICallback("toggleDev", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("snipe-menu:client:toggleDev")
        
        if isTerminal == "no" then
            TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", Config.Locales.dev_mode_enabled)
            isTerminal = "yes"
            devMode = true
        else
            isTerminal = "no"
            devMode = false
        end
        
        TriggerServerEvent("snipe-menu:server:toggleDev", devMode)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.dev_mode_exploit)
    end
end)

-- NUI Callback: Toggle debug mode
RegisterNUICallback("toggleDebug", function(data, cb)
    if hasAdminPerms then
        if isDebug == "no" then
            TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", Config.Locales.debug_mode_enabled)
            isDebug = "yes"
            debugMode = true
            StartDebugThread()
        else
            isDebug = "no"
            debugMode = false
        end
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.debug_mode_exploit)
    end
end)

-- NUI Callback: Toggle duty
RegisterNUICallback("toggleDuty", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("snipe-menu:client:toggleDuty")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.toggle_duty_exploit)
    end
    cb("ok")
end)

-- Export: Check if dev mode is enabled
function isDevMode()
    return devMode
end

exports("isDevMode", isDevMode)
