-- Spectate System Client

local savedCoords = nil
isSpectateEnabled = false
local isTransitioning = false
local targetPed = nil
local targetPlayer = nil
local targetServerId = nil

CONTROLS = {
    next = 187,
    prev = 188,
    exit = 194
}

local INSTRUCTIONS = {
    { "Exit Spectate", CONTROLS.exit },
    { "Previous Player", CONTROLS.prev },
    { "Next Player", CONTROLS.next }
}

-- Helper: Get coords below target for spectating
function GetSpectateCoords(coords)
    return vec3(coords.x, coords.y, coords.z - 15.0)
end

-- Helper: Toggle player visibility and freeze state
function SetSpectateState(enabled)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, enabled)
    SetEntityVisible(ped, not enabled, 0)

    if enabled then
        TaskLeaveAnyVehicle(ped, 0, 16)
    end
end

-- Helper: Teleport with collision loading
function TeleportToCoords(coords)
    if not IsScreenFadedOut() then
        DoScreenFadeOut(500)
    end

    while not IsScreenFadedOut() do
        Wait(5)
    end

    local ped = PlayerPedId()
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)

    local attempts = 0
    while not HasCollisionLoadedAroundEntity(ped) and attempts < 1000 do
        Wait(5)
        attempts = attempts + 1
    end
end

-- Exit spectate mode
function ExitSpectate()
    isSpectateEnabled = false
    isTransitioning = true

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(5)
    end

    NetworkSetInSpectatorMode(false, nil)
    SetMinimapInSpectatorMode(false, nil)

    if savedCoords then
        pcall(TeleportToCoords, savedCoords)
    else
        SetEntityCoords(PlayerPedId(), vec3(Config.SafeCoords.x, Config.SafeCoords.y, Config.SafeCoords.z))
    end

    SetSpectateState(false)

    targetPed = nil
    targetPlayer = nil
    targetServerId = nil
    savedCoords = nil

    DoScreenFadeIn(500)
    while IsScreenFadingIn() do
        Wait(5)
    end

    isTransitioning = false
    TriggerServerEvent("snipe-menu:server:endSpectate")
end

-- Thread to follow spectated player
function StartFollowThread()
    CreateThread(function()
        local currentTarget = targetServerId

        while isSpectateEnabled and targetServerId == currentTarget do
            if not DoesEntityExist(targetPed) then
                local newPed = GetPlayerPed(targetPlayer)
                if newPed > 0 then
                    targetPed = newPed
                else
                    ExitSpectate()
                    break
                end
            end

            local spectatePos = GetSpectateCoords(GetEntityCoords(targetPed))
            SetEntityCoords(PlayerPedId(), spectatePos.x, spectatePos.y, spectatePos.z, 0, 0, 0, false)

            Wait(500)
        end
    end)
end

-- Cycle to next/prev player
function CyclePlayer(isNext)
    if IsPauseMenuActive() or not isSpectateEnabled then
        return
    end

    if isTransitioning then
        print("Currently in transition moment, cannot change target")
        return
    end

    if targetServerId == nil then
        print("Cannot cycle prev/next player because current one is not saved")
        return
    end

    TriggerServerEvent("snipe-menu:server:cycle", targetServerId, isNext)
end

-- Handle control inputs
function HandleSpectateControls()
    if IsControlJustPressed(0, CONTROLS.next) then
        CyclePlayer(true)
    end

    if IsControlJustPressed(0, CONTROLS.prev) then
        CyclePlayer(false)
    end

    if IsControlJustPressed(0, CONTROLS.exit) then
        ExitSpectate()
    end
end

-- Setup instructional buttons scaleform
function SetupInstructionalButtons(buttons)
    local scaleform = RequestScaleformMovie("instructional_buttons")

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(10)
    end

    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for index, button in ipairs(buttons) do
        local controlButton = GetControlInstructionalButton(0, button[2], true)

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(index - 1)
        ScaleformMovieMethodAddParamPlayerNameString(controlButton)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(button[1])
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end

-- Start spectate UI threads
function StartSpectateUI()
    -- Text display thread
    CreateThread(function()
        while isSpectateEnabled do
            if targetServerId then
                local targetName = GetPlayerName(GetPlayerFromServerId(targetServerId))
                drawTxt(0.9, 0.88, 0.6, 1.0, 1.0, Config.Locales.spectating .. "[" .. targetServerId .. "] " .. targetName, 255, 0, 0, 255)
            end

            drawTxt(0.9, 0.9, 0.4, 0.5, 0.5, Config.Locales.switch_player_spectate, 255, 255, 255, 255)
            drawTxt(0.9, 0.92, 0.4, 0.5, 0.5, Config.Locales.backspace_to_exit, 255, 255, 255, 255)

            Wait(0)
        end
    end)

    -- Control handler thread
    CreateThread(function()
        while isSpectateEnabled do
            HandleSpectateControls()
            Wait(5)
        end
    end)
end

RegisterNUICallback("spectatePlayer", function(data, callback)
    if not hasAdminPerms then return end

    local myServerId = GetPlayerServerId(PlayerId())
    local targetId = tonumber(data.selectedPlayer.id)

    if myServerId == targetId then
        callback("ok")
        return
    end

    TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
    TriggerServerEvent("snipe-menu:server:spectatePlayer", targetId)
    callback("ok")
end)

RegisterNetEvent("snipe-menu:client:failed", function()
    -- Empty handler for failed spectate attempts
end)

RegisterNetEvent("snipe-menu:client:spectatePlayer", function(targetId, coords)
    if isTransitioning then
        ExitSpectate()
    end

    local myServerId = GetPlayerServerId(PlayerId())
    if targetId == myServerId then
        print("Cannot spectate self")
        return
    end

    isTransitioning = true
    targetPed = nil
    targetPlayer = nil
    targetServerId = nil

    -- Save current position if not already spectating
    if savedCoords == nil then
        savedCoords = GetEntityCoords(PlayerPedId())
    end

    SetSpectateState(true)

    local spectatePos = GetSpectateCoords(coords)
    local success = pcall(TeleportToCoords, spectatePos)
    if not success then
        ExitSpectate()
        return
    end

    -- Wait for target player to resolve
    local attempts = 0
    local player = -1
    local ped = 0

    while (player <= 0 or ped <= 0) and attempts < 300 do
        attempts = attempts + 1
        player = GetPlayerFromServerId(targetId)
        ped = GetPlayerPed(player)
        Wait(50)
    end

    if player <= 0 or ped <= 0 then
        pcall(TeleportToCoords, savedCoords)
        SetSpectateState(false)
        DoScreenFadeIn(500)
        while IsScreenFadedOut() do Wait(5) end
        isTransitioning = false
        savedCoords = nil
        return
    end

    targetPed = ped
    targetPlayer = player
    targetServerId = targetId
    isTransitioning = false

    NetworkSetInSpectatorMode(true, ped)
    SetMinimapInSpectatorMode(true, ped)

    if not isSpectateEnabled then
        isSpectateEnabled = true
        StartSpectateUI()
    end

    StartFollowThread()

    DoScreenFadeIn(500)
    while IsScreenFadedOut() do Wait(5) end
end)

RegisterNUICallback("spectatePlayer", function(data, callback)
    if not hasAdminPerms then return end

    local myServerId = GetPlayerServerId(PlayerId())
    local targetId = tonumber(data.selectedPlayer.id)

    if myServerId == targetId then
        callback("ok")
        return
    end

    TriggerEvent("snipe-menu:client:forceCloseAdminMenu")
    TriggerServerEvent("snipe-menu:server:startSpectating", targetId)
    callback("ok")
end)
