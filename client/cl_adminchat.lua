-- Admin Chat Client - NUI Callbacks

RegisterNUICallback("getAdminChats", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getAdminChats", function(result)
        p:resolve(result)
    end)

    local chatData = Citizen.Await(p)

    callback({
        chats = chatData.chats,
        currUserName = chatData.currUserName
    })
end)

RegisterNUICallback("adminMessageSent", function(data, callback)
    if not hasAdminPerms then return end

    TriggerServerEvent("sp-adminmenu:server:adminMessageSent", data)

    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getAdminChats", function(result)
        p:resolve(result)
    end)

    local chatData = Citizen.Await(p)

    TriggerServerEvent("sp-adminmenu:server:notifyAdmins", chatData.currUserName)

    callback({ chats = chatData.chats })
end)

RegisterNUICallback("refreshChats", function(data, callback)
    if not hasAdminPerms then return end

    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getAdminChats", function(result)
        p:resolve(result)
    end)

    local chatData = Citizen.Await(p)

    callback({ chats = chatData.chats })
end)
