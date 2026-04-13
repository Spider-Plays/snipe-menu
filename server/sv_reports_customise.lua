
RegisterNetEvent("sp-adminmenu:server:toggleReports", function()
    local src = source
    if not onlineAdmins[src] then 
        SendLogs(src, "exploit", "Exploit detected: sp-adminmenu:server:toggleReports")
        DropPlayer(src, "Exploit detected")
        return
    end
    if not hideNoti[src] then
        hideNoti[src] = true
        ShowNotification(src, "You will no longer get report notifications", "error")
    else
        hideNoti[src] = nil
        ShowNotification(src, "You will now get report notifications", "success")
    end
end)

RegisterNetEvent("sp-adminmenu:server:reportSent", function(data)
    local source = source
    local userName = GetPlayerName(source)
    local userChatInfo = {
        sender = userName,
        message = data,
        time = os.time()
    }
    if reports[userName] == nil then
        reports[userName] = {}
    end
    if not reports2[userName] or reports2[userName] ~= source then
        reports2[userName] = source
    end

    if not reports3[userName] then
        reports3[userName] = playerIdToIdentifier[source] or GetPlayerFrameworkIdentifier(source)
    end
    SendLogs(source, "report", Config.Locales["report_sent"]..": "..data)
    table.insert(reports[userName], userChatInfo)
    for k, v in pairs(onlineAdmins) do
        if v and not hideNoti[k] then
            ShowNotification(k, Config.Locales["report_received_message"].." "..userName, "success")
            TriggerClientEvent("sp-adminmenu:client:showReportUnread", k)
        end
    end
end)

RegisterNetEvent("sp-adminmenu:server:adminReply", function(message, userName)
    local source = source
    if not onlineAdmins[source] then 
        SendLogs(source, "exploit", "Exploit detected: sp-adminmenu:server:adminReply")
        DropPlayer(source, "Exploit detected")
        return
    end
    local adminName = GetPlayerName(source)
    local adminChatInfo = {
        sender = adminName,
        message = message,
        time = os.time()
    }
    table.insert(reports[userName], adminChatInfo)
    SendLogs(source, "report",Config.Locales["report_replied"].." "..userName..": "..message)
    ShowNotification(reports2[userName], Config.Locales["admin_replied"], "success")
    TriggerClientEvent("sp-adminmenu:client:showReportUnread", reports2[userName])
end)

function ReportClosed(playerId, userName, closedBySrc)
    print("Report closed for "..userName.." ("..playerId..")")
    print("Report closed by "..GetPlayerName(closedBySrc).." ("..closedBySrc..")")
    -- This is trigered when the report is closed for player with playerId and userName
end