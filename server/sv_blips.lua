-- Player Blips System - Server Side

onlinePlayer = {}
droppedPlayers = {}
playerNames = {}
playersTable = {}
playerIdToIdentifier = {}

local playerPeds = {}
local blipSubscribers = {}
local blipThreadRunning = false

-- Helper: Get display name for a player (framework name or fallback)
function GetPlayerDisplayName(playerId)
    if Config.ShowInGameNamesForNamesAndBlips then
        if playerNames[playerId] == nil then
            playerNames[playerId] = GetFrameworkName(playerId)
        end
        return playerNames[playerId] or GetPlayerName(playerId)
    end
    return GetPlayerName(playerId)
end

-- Helper: Build player blip data for all online players
function BuildBlipData()
    local blipData = {}

    for playerId, isOnline in pairs(onlinePlayer) do
        if isOnline then
            if not playerPeds[playerId] then
                playerPeds[playerId] = GetPlayerPed(playerId)
            end

            local coords = GetEntityCoords(playerPeds[playerId])
            local heading = GetEntityHeading(playerPeds[playerId])
            local displayName = GetPlayerDisplayName(playerId)

            blipData[#blipData + 1] = {
                id = playerId,
                name = displayName,
                coords = coords,
                heading = heading
            }
        end
    end

    return blipData
end

-- Helper: Validate admin and kick exploiters
function ValidateAdmin(playerId, eventName)
    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: " .. eventName)
        DropPlayer(playerId, "Exploit detected")
        return false
    end
    return true
end

-- Helper: Clear player data on disconnect
function ClearPlayerData(playerId)
    if onlinePlayer[playerId] then
        onlinePlayer[playerId] = nil
    end
    if onlineAdmins[playerId] then
        onlineAdmins[playerId] = nil
    end
    if sendBackCoords[playerId] then
        sendBackCoords[playerId] = nil
    end
    if enabledAdminTagsList[playerId] then
        enabledAdminTagsList[playerId] = nil
    end
    if playerPeds[playerId] then
        playerPeds[playerId] = nil
    end
    if playerNames[playerId] then
        playerNames[playerId] = nil
    end
    if adminRoleLabel[playerId] then
        adminRoleLabel[playerId] = nil
    end
end

RegisterServerEvent("snipe-menu:server:playerLoaded", function()
    local playerId = source
    local playerName = GetPlayerName(playerId)

    -- Update reports2 if player exists with different ID
    if reports2[playerName] and reports2[playerName] ~= playerId then
        reports2[playerName] = playerId
    end

    playerNames[playerId] = GetFrameworkName(playerId)

    if not onlinePlayer[playerId] then
        local displayName
        if Config.ShowInGameNames and playerNames[playerId] then
            displayName = playerNames[playerId]
        else
            displayName = playerName
        end

        playersTable[#playersTable + 1] = {
            id = playerId,
            name = displayName
        }

        onlinePlayer[playerId] = true
        playerIdToIdentifier[playerId] = GetPlayerFrameworkIdentifier(playerId)
    end
end)

AddEventHandler("playerDropped", function()
    local playerId = source

    TriggerClientEvent("snipe-menu:client:playerDropped", -1, playerId)

    -- Remove from players table
    for index, playerData in pairs(playersTable) do
        if playerData.id == playerId then
            table.remove(playersTable, index)
            break
        end
    end

    ClearPlayerData(playerId)

    -- Add to dropped players list
    droppedPlayers[#droppedPlayers + 1] = {
        id = playerId,
        name = GetPlayerName(playerId),
        timeOfDisconnect = os.time()
    }
end)

RegisterNetEvent("snipe-menu:server:blipsStarted", function(enabled)
    local playerId = source

    if not ValidateAdmin(playerId, "snipe-menu:server:blipsStarted") then
        return
    end

    if enabled then
        blipSubscribers[playerId] = true
        if not blipThreadRunning then
            StartBlipThread()
        end
    else
        blipSubscribers[playerId] = nil
        if not next(blipSubscribers) then
            blipThreadRunning = false
        end
    end
end)

function StartBlipThread()
    blipThreadRunning = true

    CreateThread(function()
        while blipThreadRunning do
            local blipData = BuildBlipData()

            for subscriberId in pairs(blipSubscribers) do
                TriggerClientEvent("snipe-menu:client:blipData", subscriberId, blipData)
            end

            Wait(math.random(3000, 5000))
        end
    end)
end

CreateCallback("snipe-menu:server:getBlipsInfo", function(source, callback)
    if not ValidateAdmin(source, "snipe-menu:server:getBlipsInfo") then
        return
    end

    callback(BuildBlipData())
end)
