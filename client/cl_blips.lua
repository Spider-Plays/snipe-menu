-- Blips & Names System Client

blipThread = false
toggleNameThread = false
Tag = {}

local playerBlips = {}

function UpdatePlayerBlip(playerId, playerName, coords, heading, serverId)
    local localServerId = GetPlayerServerId(PlayerId())

    -- Don't create blip for self
    if serverId == localServerId then
        return
    end

    -- Initialize blip data for player if needed
    if not playerBlips[serverId] then
        playerBlips[serverId] = {}
    end

    if not heading then
        return
    end

    local playerPed = GetPlayerPed(tonumber(playerId))
    local blipHandle = GetBlipFromEntity(playerPed)
    local isPlayerActive = NetworkIsPlayerActive(tonumber(playerId))

    if isPlayerActive then
        -- Player is active, handle blip creation/update
        if not DoesBlipExist(blipHandle) then
            -- Remove old blip if exists
            if playerBlips[serverId] and playerBlips[serverId].blip then
                RemoveBlip(playerBlips[serverId].blip)
            end

            -- Create new blip
            if NetworkIsPlayerActive(tonumber(playerId)) then
                blipHandle = AddBlipForEntity(playerPed)
            else
                blipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
            end

            SetBlipSprite(blipHandle, 1)
            playerBlips[serverId].entity = true
        end
    else
        -- Player not active
        if playerBlips[serverId] and playerBlips[serverId].entity then
            RemoveBlip(playerBlips[serverId].blip)
            playerBlips[serverId] = nil

            blipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blipHandle, 1)
        elseif playerBlips[serverId] and playerBlips[serverId].blip then
            SetBlipCoords(playerBlips[serverId].blip, coords.x, coords.y, coords.z)
            SetBlipSprite(playerBlips[serverId].blip, 1)
            blipHandle = playerBlips[serverId].blip
        else
            blipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blipHandle, 1)
        end
    end

    -- Configure blip appearance
    SetBlipCategory(blipHandle, 7)
    ShowHeadingIndicatorOnBlip(blipHandle, true)
    SetBlipRotation(blipHandle, math.ceil(heading))
    SetBlipScale(blipHandle, 1.0)
    SetBlipAsShortRange(blipHandle, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(playerName)
    EndTextCommandSetBlipName(blipHandle)

    -- Store blip reference
    if not playerBlips[serverId] then
        playerBlips[serverId] = {}
    end
    playerBlips[serverId].blip = blipHandle
end

function StartBlipThread()
    blipThread = not blipThread
end

RegisterNetEvent("snipe-menu:client:blipData", function(blipData)
    for _, player in pairs(blipData) do
        local playerId = GetPlayerFromServerId(player.id)
        UpdatePlayerBlip(playerId, player.name, player.coords, player.heading, player.id)
    end
end)

function ToggleBlips()
    if hasAdminPerms then
        if not blipThread then
            enabledButtons[#enabledButtons + 1] = "Toggle Blips"
            ShowNotification(Config.Locales.blip_enabled, "success")
            TriggerServerEvent("snipe-menu:server:blipsStarted", true)
            blipThread = true
        else
            -- Remove from enabled buttons
            for index, button in pairs(enabledButtons) do
                if button == "Toggle Blips" then
                    table.remove(enabledButtons, index)
                end
            end

            ShowNotification(Config.Locales.blip_disabled, "error")
            TriggerServerEvent("snipe-menu:server:blipsStarted", false)
            blipThread = false

            -- Clean up all blips
            for _, blipData in pairs(playerBlips) do
                RemoveBlip(blipData.blip)
            end
            playerBlips = {}
        end
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.blip_exploit)
    end
end

function forceCloseBlips()
    if blipThread then
        TriggerServerEvent("snipe-menu:server:blipsStarted", false)

        for _, blipData in pairs(playerBlips) do
            RemoveBlip(blipData.blip)
        end

        playerBlips = {}
        blipThread = false
    end
end

RegisterNetEvent("snipe-menu:client:toggleNames", function()
    if hasAdminPerms then
        if not toggleNameThread then
            enabledButtons[#enabledButtons + 1] = "Toggle Names"
            ShowNotification(Config.Locales.name_enabled, "success")
            ToggleNames()
        else
            for index, button in pairs(enabledButtons) do
                if button == "Toggle Names" then
                    table.remove(enabledButtons, index)
                end
            end
            ShowNotification(Config.Locales.name_disabled, "error")
            ToggleNames()
        end
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.toggle_name_exploit)
    end
end)

RegisterNUICallback("toggleBlips", function(data, callback)
    enabledButtons = data.panelsClicked

    if hasAdminPerms then
        ToggleBlips()
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.blips_exploit)
    end
end)

RegisterNUICallback("toggleNames", function(data, callback)
    enabledButtons = data.panelsClicked

    if hasAdminPerms then
        ToggleNames()
        callback("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.toggle_name_exploit)
    end
end)
