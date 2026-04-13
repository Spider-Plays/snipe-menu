-- Reports / Ticket System - Server Side

reports = {}
reports2 = {}
reports3 = {}
teleportedUsingReports = {}
hideNoti = {}

-- Helper: Get the latest message time from a report thread
function GetLatestMessageTime(messageList)
    local latestTime = 0
    for _, message in pairs(messageList) do
        if message.time > latestTime then
            latestTime = message.time
        end
    end
    return latestTime
end

-- Helper: Check if sender is an admin (not the reporter)
function IsAdminMessage(senderName, reporterName)
    local senderId = reports2[senderName]
    return onlineAdmins[senderId] and senderName ~= reporterName
end

-- Helper: Format a chat message for transcript
function FormatTranscriptMessage(message, isAdmin)
    local timestamp = os.date("%c", message.time)
    local roleLabel = isAdmin and " (Admin) : " or " : "
    return timestamp .. " - " .. message.sender .. roleLabel .. message.message .. "\n"
end

-- Helper: Build transcript from messages (handles chunking for long transcripts)
function BuildTranscript(playerName)
    local chunks = {}
    local currentChunk = ""
    local MAX_CHUNK_SIZE = 2500

    for _, message in pairs(reports[playerName]) do
        local isAdmin = IsAdminMessage(message.sender, playerName)
        local formattedMessage = FormatTranscriptMessage(message, isAdmin)
        local packedMessage = msgpack.pack_args(formattedMessage)

        if packedMessage:len() > MAX_CHUNK_SIZE then
            chunks[#chunks + 1] = currentChunk
            currentChunk = formattedMessage
        else
            currentChunk = currentChunk .. formattedMessage
        end
    end

    return chunks, currentChunk
end

-- Helper: Handle admin teleport back after closing ticket
function HandleTeleportBack(playerName, adminId)
    local teleportData = teleportedUsingReports[playerName]
    if teleportData and teleportData.adminId == adminId then
        TriggerClientEvent("snipe-menu:client:teleporttoplayer", teleportData.adminId, teleportData.oldCoords)
    end
    teleportedUsingReports[playerName] = nil
end

CreateCallback("snipe-menu:server:getReportsForUser", function(source, callback, _)
    local playerName = GetPlayerName(source)
    local reportData = reports[playerName]

    callback({
        chats = reportData or {},
        currentUser = playerName
    })
end)

CreateCallback("snipe-menu:server:getPlayersWithReports", function(source, callback)
    local result = { players = {} }

    for playerName, messages in pairs(reports) do
        local latestTime = GetLatestMessageTime(messages)

        table.insert(result.players, {
            name = playerName,
            id = reports2[playerName],
            time = latestTime,
            identifier = reports3[playerName]
        })
    end

    callback(result)
end)

CreateCallback("snipe-menu:server:getUserChats", function(source, callback, playerName)
    callback({
        chats = reports[playerName],
        currentUser = GetPlayerName(source)
    })
end)

CreateCallback("snipe-menu:server:closeTicket", function(source, callback, targetId, fallbackName)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:closeTicket")
        DropPlayer(source, "Exploit detected")
        return
    end

    local playerName = GetPlayerName(targetId) or fallbackName
    local chunks, finalChunk = BuildTranscript(playerName)

    -- Send transcript chunks with delay
    for _, chunk in pairs(chunks) do
        SendLogs(source, "transcript", chunk)
        Wait(1000)
    end
    SendLogs(source, "transcript", finalChunk)

    HandleTeleportBack(playerName, source)

    ShowNotification(reports2[playerName], Config.Locales.ticket_closed, "success")
    TriggerClientEvent("snipe-menu:client:hideReportUnread", reports2[playerName])
    ReportClosed(reports2[playerName], playerName, source)

    reports[playerName] = nil
    callback(true)
end)

-- Export for external ticket closing
function CloseTicket(targetId, fallbackName)
    local playerName = GetPlayerName(targetId) or fallbackName
    local chunks, finalChunk = BuildTranscript(playerName)

    for _, chunk in pairs(chunks) do
        SendLogs(source, "transcript", chunk)
        Wait(1000)
    end
    SendLogs(source, "transcript", finalChunk)

    HandleTeleportBack(playerName, source)

    ShowNotification(reports2[playerName], Config.Locales.ticket_closed, "success")
    TriggerClientEvent("snipe-menu:client:hideReportUnread", reports2[playerName])

    reports[playerName] = nil
end
exports("CloseTicket", CloseTicket)

RegisterServerEvent("snipe-menu:server:playerTeleportFromReport", function(adminOldCoords, targetId)
    local playerId = source

    if playerId == targetId then
        return
    end

    if playerId == 0 then
        SendLogs(playerId, "exploit", Config.Locales.teleport_player_event_exploit)
        return
    end

    if not onlineAdmins[playerId] then
        return
    end

    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    local targetName = GetPlayerName(targetId)

    teleportedUsingReports[targetName] = {
        oldCoords = adminOldCoords,
        adminId = playerId
    }

    SendLogs(playerId, "triggered", Config.Locales.teleport_player_used .. targetName)
    TriggerClientEvent("snipe-menu:client:teleporttoplayer", playerId, targetCoords)
end)
