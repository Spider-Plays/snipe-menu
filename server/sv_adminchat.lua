-- Admin Chat System - Server Side

local adminChats = {}

CreateCallback("snipe-menu:server:getAdminChats", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:getAdminChats")
        DropPlayer(source, "Exploit detected")
        return
    end

    callback({
        chats = adminChats,
        currUserName = GetPlayerName(source)
    })
end)

RegisterServerEvent("snipe-menu:server:adminMessageSent", function(messageData)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: snipe-menu:server:adminMessageSent")
        DropPlayer(playerId, "Exploit detected")
        return
    end

    local newMessage = {
        id = #adminChats + 1,
        name = messageData.userName,
        msg = messageData.message
    }

    table.insert(adminChats, newMessage)
end)
