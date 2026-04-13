local playerDataCache = {}
local groupedPlayers = {}
local playersInRange = {}
local playersOutOfRange = {}

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    
    local textLength = string.len(text) / 370
    DrawRect(0.0, 0.0125, 0.017 + textLength, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function RemovePlayerDataFromGroups(playerId)
    for index, group in pairs(groupedPlayers) do
        if group[playerId] then
            group[playerId] = nil
            
            if next(group) == nil then
                table.remove(groupedPlayers, index)
            end
        end
    end
end

function FindPlayerGroupIndex(playerId)
    for index, group in pairs(groupedPlayers) do
        if group[playerId] then
            return index
        end
    end
    return nil
end

function CountTableEntries(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function RemovePlayerFromList(playerId)
    for index, playerData in pairs(players) do
        if playerData.id == playerId then
            table.remove(players, index)
        end
    end
    
    for index, cachedData in pairs(playerDataCache) do
        if cachedData.id == playerId then
            playerDataCache[index] = nil
        end
    end
end

function CleanupOnClose()
    playerDataCache = {}
    groupedPlayers = {}
    playersInRange = {}
    playersOutOfRange = {}
end

RegisterNetEvent("sp-adminmenu:client:playerDropped", function(playerId)
    if playersInRange[playerId] then
        RemovePlayerFromList(playerId)
        RemovePlayerDataFromGroups(playerId)
        playersInRange[playerId] = nil
    end
end)

function StartNamesThread()
    CreateThread(function()
        while toggleNameThread do
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for _, group in ipairs(groupedPlayers) do
                local displayCount = 0
                local groupCount = CountTableEntries(group)
                
                if groupCount > 1 then
                    local _, firstPlayer = next(group)
                    local groupCoords = firstPlayer.coords
                    
                    for _, playerData in pairs(group) do
                        if displayCount >= 3 then
                            local zOffset = 50 - (10.0 * displayCount)
                            local remaining = math.abs(#group - (displayCount + 1))
                            
                            DrawText3D(groupCoords.x, groupCoords.y, groupCoords.z + zOffset, "And " .. remaining .. " More..")
                            
                            if Config.ShowLines then
                                DrawLine(
                                    playerCoords.x, playerCoords.y, playerCoords.z + 0.1,
                                    playerData.coords.x, playerData.coords.y, playerData.coords.z,
                                    Config.LineColor.r, Config.LineColor.g, Config.LineColor.b, 255
                                )
                            end
                            break
                        end
                        
                        if playerData.id ~= GetPlayerServerId(PlayerId()) then
                            local zOffset = 50 - (10.0 * displayCount)
                            DrawText3D(groupCoords.x, groupCoords.y, groupCoords.z + zOffset, 
                                "[" .. playerData.id .. "] " .. playerData.name)
                            displayCount = displayCount + 1
                        end
                    end
                else
                    for _, playerData in pairs(group) do
                        if playerData.id ~= GetPlayerServerId(PlayerId()) then
                            DrawText3D(playerData.coords.x, playerData.coords.y, playerData.coords.z, 
                                "[" .. playerData.id .. "] " .. playerData.name)
                            
                            if Config.ShowLines then
                                DrawLine(
                                    playerCoords.x, playerCoords.y, playerCoords.z + 0.1,
                                    playerData.coords.x, playerData.coords.y, playerData.coords.z,
                                    Config.LineColor.r, Config.LineColor.g, Config.LineColor.b, 255
                                )
                            end
                        end
                    end
                end
            end
            
            Wait(3)
        end
    end)
end

function StartDistanceThread()
    CreateThread(function()
        while toggleNameThread do
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for _, playerData in pairs(players) do
                if playerData.id ~= GetPlayerServerId(PlayerId()) then
                    local playerFromServer = GetPlayerFromServerId(playerData.id)
                    
                    if NetworkIsPlayerActive(playerFromServer) then
                        local boneCoords = GetPedBoneCoords(GetPlayerPed(playerFromServer), 31086)
                        coords = vec3(boneCoords.x, boneCoords.y, boneCoords.z + 0.5)
                    else
                        coords = vec3(playerData.coords.x, playerData.coords.y, playerData.coords.z + 1.0)
                    end
                    
                    coords = coords or playerData.coords
                    
                    local distance = #(playerCoords - playerData.coords)
                    
                    if distance <= 450.0 then
                        if not playerDataCache[playerData.id] then
                            playerDataCache[playerData.id] = {
                                coords = coords,
                                id = playerData.id,
                                name = playerData.name,
                                distance = #(playerCoords - playerData.coords)
                            }
                        end
                    elseif distance > 450.0 then
                        if playerDataCache[playerData.id] then
                            if not playersInRange[playerData.id] then
                                if not playersOutOfRange[playerData.id] then
                                    goto continue
                                end
                                
                                RemovePlayerDataFromGroups(playerData.id)
                                
                                if playersInRange[playerData.id] then
                                    playersInRange[playerData.id] = nil
                                end
                                
                                if playersOutOfRange[playerData.id] then
                                    playersOutOfRange[playerData.id] = nil
                                end
                            end
                            
                            ::continue::
                            playerDataCache[playerData.id] = nil
                        end
                    elseif distance <= 450.0 then
                        if playerDataCache[playerData.id] then
                            playerDataCache[playerData.id].coords = coords
                            playerDataCache[playerData.id].distance = #(playerCoords - playerData.coords)
                        end
                    end
                else
                    local selfCoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
                    
                    playerDataCache[playerData.id] = {
                        coords = selfCoords,
                        id = playerData.id,
                        name = playerData.name,
                        distance = #(playerCoords - playerData.coords)
                    }
                end
            end
            
            Wait(10)
        end
    end)
end

function GroupNearbyPlayers(playerData)
    for _, cachedPlayer in pairs(playerDataCache) do
        local distanceBetween = #(playerData.coords - cachedPlayer.coords)
        
        if distanceBetween < 50 and playerData.id ~= cachedPlayer.id then
            if not playersInRange[cachedPlayer.id] then
                local groupIndex = FindPlayerGroupIndex(playerData.id)
                
                groupedPlayers[groupIndex][cachedPlayer.id] = cachedPlayer
                playersInRange[cachedPlayer.id] = true
                
                GroupNearbyPlayers(cachedPlayer)
            elseif playersOutOfRange[cachedPlayer.id] then
                RemovePlayerDataFromGroups(cachedPlayer.id)
                
                local groupIndex = FindPlayerGroupIndex(playerData.id)
                groupedPlayers[groupIndex][cachedPlayer.id] = cachedPlayer
                playersInRange[cachedPlayer.id] = true
                playersOutOfRange[cachedPlayer.id] = false
                
                GroupNearbyPlayers(cachedPlayer)
            else
                local playerGroupIndex = FindPlayerGroupIndex(playerData.id)
                local cachedGroupIndex = FindPlayerGroupIndex(cachedPlayer.id)
                
                if cachedGroupIndex ~= playerGroupIndex then
                    RemovePlayerDataFromGroups(cachedPlayer.id)
                    
                    local groupIndex = FindPlayerGroupIndex(playerData.id)
                    groupedPlayers[groupIndex][cachedPlayer.id] = cachedPlayer
                    playersInRange[cachedPlayer.id] = true
                    
                    GroupNearbyPlayers(cachedPlayer)
                end
            end
        end
    end
end

function StartGroupThread()
    CreateThread(function()
        while toggleNameThread do
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for _, playerData in pairs(playerDataCache) do
                if playerData.distance < 400 then
                    if playerData.distance > 120 then
                        if not playersInRange[playerData.id] then
                            groupedPlayers[#groupedPlayers + 1] = {}
                            
                            if groupedPlayers[#groupedPlayers] then
                                groupedPlayers[#groupedPlayers][playerData.id] = playerData
                            end
                            
                            playersInRange[playerData.id] = true
                            GroupNearbyPlayers(playerData)
                        elseif playersOutOfRange[playerData.id] then
                            RemovePlayerDataFromGroups(playerData.id)
                            
                            groupedPlayers[#groupedPlayers + 1] = {}
                            
                            if groupedPlayers[#groupedPlayers] then
                                groupedPlayers[#groupedPlayers][playerData.id] = playerData
                            end
                            
                            playersInRange[playerData.id] = true
                            playersOutOfRange[playerData.id] = false
                            
                            GroupNearbyPlayers(playerData)
                        end
                    else
                        if playersInRange[playerData.id] then
                            if not playersOutOfRange[playerData.id] then
                                RemovePlayerDataFromGroups(playerData.id)
                                
                                groupedPlayers[#groupedPlayers + 1] = {}
                                
                                if groupedPlayers[#groupedPlayers] then
                                    groupedPlayers[#groupedPlayers][playerData.id] = playerData
                                end
                                
                                playersInRange[playerData.id] = true
                                playersOutOfRange[playerData.id] = true
                            end
                        else
                            groupedPlayers[#groupedPlayers + 1] = {}
                            
                            if groupedPlayers[#groupedPlayers] then
                                groupedPlayers[#groupedPlayers][playerData.id] = playerData
                            end
                            
                            playersInRange[playerData.id] = true
                            GroupNearbyPlayers(playerData)
                        end
                    end
                end
            end
            
            Wait(100)
        end
    end)
end

