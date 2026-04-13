if Config.Ambulance ~= "esx_ambulance" then return end


RegisterServerEvent('sp-adminmenu:server:reviveplayer', function(otherPlayerId)
    local src = source
    if src ~= 0 and onlineAdmins[src] then
        SendLogs(src, "triggered", Config.Locales["revive_player_used"]..GetPlayerName(otherPlayerId))
        TriggerClientEvent('esx_ambulancejob:revive', otherPlayerId)
    else
        SendLogs(src, "exploit", Config.Locales["revive_exploit_event"])
    end
end)

RegisterServerEvent('sp-adminmenu:server:healPlayer', function(otherPlayerId)
    local src = source
    if src ~= 0 and onlineAdmins[src] then
        TriggerClientEvent("esx_basicneeds:healPlayer", otherPlayerId)
    else
        SendLogs(src, "exploit", Config.Locales["heal_player_exploit"])
    end
end)
