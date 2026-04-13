CreateCallback("snipe-menu:server:getOfflinePlayers", function(source, cb)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:getOfflinePlayers") 
        DropPlayer(source, "Exploit detected")
        return
    end
    cb(GetOfflinePlayers())
end)

CreateCallback("snipe-menu:server:getAllOwnedVehicles", function(source, cb)
    if not onlineAdmins[source] then 
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:getAllOwnedVehicles")
        DropPlayer(source, "Exploit detected")
        return
    end
    cb(GetAllOwnedVehicles())
end)
