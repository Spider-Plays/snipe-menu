-- Spectate System - Server Side

local spectateData = {}

function StartSpectating(targetId)
    local playerId = source

    if not onlineAdmins[playerId] then
        return
    end

    if type(targetId) ~= "string" and type(targetId) ~= "number" then
        return
    end

    targetId = tonumber(targetId)

    local targetPed = GetPlayerPed(targetId)
    if not targetPed then
        return
    end

    local targetBucket = GetPlayerRoutingBucket(targetId)
    local adminBucket = GetPlayerRoutingBucket(playerId)
    local adminState = Player(playerId).state

    -- Handle routing bucket switch for spectating
    if adminBucket ~= targetBucket then
        if adminState.__spectateReturnBucket == nil then
            adminState.__spectateReturnBucket = adminBucket
        end
        SetPlayerRoutingBucket(playerId, targetBucket)
    end

    local targetCoords = GetEntityCoords(targetPed)
    TriggerClientEvent("snipe-menu:client:spectatePlayer", playerId, targetId, targetCoords)

    SendLogs(playerId, "triggered", Config.Locales.spectate_player_used .. "(Source: " .. targetId .. ") " .. GetPlayerName(targetId))
end

RegisterNetEvent("snipe-menu:server:startSpectating", StartSpectating)

function tableIndexOf(tbl, value)
    for i = 1, #tbl do
        if tbl[i] == value then
            return i
        end
    end
    return -1
end

RegisterNetEvent("snipe-menu:server:cycle", function(currentTargetId, isNext)
    local playerId = source

    if not onlineAdmins[playerId] then
        return
    end

    local players = GetPlayers()

    if #players <= 2 then
        return TriggerClientEvent("snipe-menu:client:failed", playerId)
    end

    -- Remove self from player list
    local selfIndex = tableIndexOf(players, tostring(playerId))
    table.remove(players, selfIndex)

    local nextTarget = nil
    local currentIndex = tableIndexOf(players, tostring(currentTargetId))

    if currentIndex < 0 then
        nextTarget = players[1]
    elseif isNext then
        nextTarget = players[currentIndex + 1] or players[1]
    else
        nextTarget = players[currentIndex - 1] or players[#players]
    end

    StartSpectating(nextTarget)
end)

RegisterNetEvent("snipe-menu:server:endSpectate", function()
    local playerId = source
    local playerState = Player(playerId).state
    local returnBucket = playerState.__spectateReturnBucket

    if returnBucket then
        SetPlayerRoutingBucket(playerId, returnBucket)
        playerState.__spectateReturnBucket = nil
    end
end)
