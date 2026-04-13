-- Troll Actions Client

-- NUI Callback: Make player drunk
RegisterNUICallback("drunkPlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:drunkPlayer", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.drunk_player_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Set player on fire
RegisterNUICallback("firePlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:firePlayer", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.fire_player_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Send player to jail box
RegisterNUICallback("sendToJailBox", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:sendToJailBox", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.send_box_player_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Slap player to sky
RegisterNUICallback("slapSky", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:slapSky", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.slap_sky_player_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Get sounds list
RegisterNUICallback("getSounds", function(data, cb)
    local sounds = {}
    
    if hasAdminPerms then
        for _, sound in pairs(Config.Sounds) do
            sounds[#sounds + 1] = {
                id = sound.soundName,
                name = sound.label
            }
        end
    end
    
    cb(sounds)
end)

-- NUI Callback: Play sound on player
RegisterNUICallback("playSoundPlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:playSound", data.selectedPlayer.id, data.selectedItem.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.play_sound_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Damage player vehicle
RegisterNUICallback("damagePlayerVehicle", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:damagePlayerVehicle", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.damage_vehicle_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Make player pee
RegisterNUICallback("peePlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:peePlayer", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.damage_vehicle_exploit)
    end
    cb("ok")
end)

-- NUI Callback: Make player poop
RegisterNUICallback("poopPlayer", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("snipe-adminmenu:server:poopPlayer", data.selectedPlayer.id)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.damage_vehicle_exploit)
    end
    cb("ok")
end)

-- Helper: Verify admin from server before executing troll action
function VerifyAdminAndExecute(adminId, action, exploitMessage)
    local p = promise.new()
    
    TriggerCallback("snipe-adminmenu:server:isAdmin", function(result)
        p:resolve(result)
    end, adminId)
    
    local isAdmin = Citizen.Await(p)
    
    if isAdmin then
        action()
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", exploitMessage)
    end
end

-- Event: Drunk player effect
RegisterNetEvent("snipe-adminmenu:client:drunkPlayer", function(adminId)
    VerifyAdminAndExecute(adminId, DrunkEffect, Config.Locales.drunk_player_exploit)
end)

-- Event: Fire player effect
RegisterNetEvent("snipe-adminmenu:client:fiePlayer", function(adminId)
    VerifyAdminAndExecute(adminId, SetPlayerOnFire, Config.Locales.fire_player_exploit)
end)

-- Event: Send to jail box
RegisterNetEvent("snipe-adminmenu:client:sendToJailBox", function(adminId)
    VerifyAdminAndExecute(adminId, SendToJailBox, Config.Locales.send_box_player_exploit)
end)

-- Event: Slap to sky
RegisterNetEvent("snipe-adminmenu:client:slapSky", function(adminId)
    VerifyAdminAndExecute(adminId, SlapSky, Config.Locales.slap_sky_player_exploit)
end)

-- Event: Damage vehicle
RegisterNetEvent("snipe-adminmenu:client:damagevehicle", function(adminId)
    VerifyAdminAndExecute(adminId, DamagePlayerVehicle, Config.Locales.damage_vehicle_exploit)
end)

-- Event: Play sound on player
RegisterNetEvent("snipe-adminmenu:client:playSound", function(soundName, adminId)
    local p = promise.new()
    
    TriggerCallback("snipe-adminmenu:server:isAdmin", function(result)
        p:resolve(result)
    end, adminId)
    
    local isAdmin = Citizen.Await(p)
    
    if isAdmin then
        PlaySound(soundName)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.slap_sky_player_exploit)
    end
end)

-- Event: Pee player effect
RegisterNetEvent("snipe-adminmenu:client:peePlayer", function(adminId)
    VerifyAdminAndExecute(adminId, PeePlayer, Config.Locales.damage_vehicle_exploit)
end)

-- Event: Poop player effect
RegisterNetEvent("snipe-adminmenu:client:poopPlayer", function(adminId)
    VerifyAdminAndExecute(adminId, PoopPlayer, Config.Locales.damage_vehicle_exploit)
end)
