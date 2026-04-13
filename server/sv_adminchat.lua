-- Admin Chat System - Server Side

local adminChats = {}

CreateCallback("sp-adminmenu:server:getAdminChats", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:getAdminChats")
        DropPlayer(source, "Exploit detected")
        return
    end

    callback({
        chats = adminChats,
        currUserName = GetPlayerName(source)
    })
end)

RegisterServerEvent("sp-adminmenu:server:adminMessageSent", function(messageData)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: sp-adminmenu:server:adminMessageSent")
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
