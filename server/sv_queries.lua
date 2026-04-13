CreateCallback("sp-adminmenu:server:getOfflinePlayers", function(source, cb)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:getOfflinePlayers") 
        DropPlayer(source, "Exploit detected")
        return
    end
    cb(GetOfflinePlayers())
end)

CreateCallback("sp-adminmenu:server:getAllOwnedVehicles", function(source, cb)
    if not onlineAdmins[source] then 
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:getAllOwnedVehicles")
        DropPlayer(source, "Exploit detected")
        return
    end
    cb(GetAllOwnedVehicles())
end)
