-- State Variables
local STORAGE_BOX_MODEL = "v_res_tre_storagebox"
local currentModel = nil
local isPlacing = false
local laserObject = nil
local currentHeading = 0.0
local currentPosition = nil
local autoSnap = true
local hoveredEntity = nil
local highlightColor = { r = 0, g = 255, b = 0, a = 200 }
local hasValidEntity = false

-- Checks if entity exists in nearbyCurrentProps and returns it with data
function FindPropByEntity(entity)
    for _, propData in pairs(nearbyCurrentProps) do
        if propData.obj == entity then
            return true, propData
        end
    end
    return false
end

-- Draws 3D text at world coordinates with background
function DrawText3Ds(posX, posY, posZ, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(posX, posY, posZ, 0)
    DrawText(0.0, 0.0)
    
    local textLength = string.len(text) / 370
    DrawRect(0.0, 0.0125, 0.017 + textLength, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Main delete laser initialization
function DeleteLaser()
    local playerPed = PlayerPedId()
    currentModel = STORAGE_BOX_MODEL

    CreateThread(function()
        while currentModel ~= nil do
            Wait(1)
            local isVehicle = false
            DisableControlAction(0, 22, true)

            if not isPlacing then
                placing2()
            end

            if currentPosition then
                local markerZ = currentPosition.z + 0.3
                DrawMarker(28, currentPosition.x, currentPosition.y, currentPosition.z + 0.2, 
                    0, 0, 0, 0, 0, 0, 0.2, 0.2, 0.2, 
                    13, 232, 255, 155, 0, 0, true, 1, 0, 0, 0)
                SetEntityCoords(laserObject, currentPosition.x, currentPosition.y, markerZ)
                SetEntityHeading(laserObject, currentHeading)
            end

            local displayInfo = {}
            
            -- Check if target is valid vehicle or entity
            local shouldShowEntityInfo = false
            if hasValidEntity and hoveredEntity ~= nil then
                if IsEntityAVehicle(hoveredEntity) then
                    shouldShowEntityInfo = true
                end
            end
            
            if not shouldShowEntityInfo then
                if IsEntityAPed(hoveredEntity) or IsEntityAnObject(hoveredEntity) then
                    shouldShowEntityInfo = true
                end
            end

            if shouldShowEntityInfo then
                displayInfo[#displayInfo + 1] = "Entity Type: "
                
                local entityLabel = PropList[GetEntityModel(hoveredEntity)]
                if not entityLabel then
                    entityLabel = "Not Found"
                end

                displayInfo = {
                    "Entity ID: " .. hoveredEntity .. "  \n",
                    "Entity Model: " .. GetEntityModel(hoveredEntity) .. "  \n",
                    "Entity Coords: " .. GetEntityCoords(hoveredEntity) .. "  \n",
                    "Entity Label : " .. entityLabel .. "  \n"
                }

                local entityType = GetEntityType(hoveredEntity)
                if entityType == 2 then
                    isVehicle = true
                    displayInfo[1] = "Entity Type: Vehicle  \n"
                    displayInfo[#displayInfo + 1] = "Press K to Warp to Vehicle  \n"
                    displayInfo[#displayInfo + 1] = "Press L to fix Vehicle  \n"
                end

                displayInfo[#displayInfo + 1] = "Press E to Delete, G to copy information  \n"

                -- Handle door entities
                if entityType == 3 then
                    local entityCoords = GetEntityCoords(hoveredEntity)
                    local isDoor, doorHash = DoorSystemFindExistingDoor(entityCoords.x, entityCoords.y, entityCoords.z, GetEntityModel(hoveredEntity))
                    
                    if isDoor then
                        displayInfo[1] = "Entity Type: Door  \n"
                        displayInfo[#displayInfo + 1] = "Press K to toggle door state  \n"
                        
                        if IsControlJustPressed(0, 311) then
                            local doorState = DoorSystemGetDoorState(doorHash)
                            if doorState == 0 then
                                DoorSystemSetDoorState(doorHash, 1, false, true)
                                ShowNotification("Door closed", "success")
                            else
                                DoorSystemSetDoorState(doorHash, 0, false, true)
                                ShowNotification("Door opened", "success")
                            end
                            TriggerServerEvent("snipe-menu:server:toggleDoor", doorHash)
                        end
                    end
                end

                -- Check if prop can be moved
                local isPropFound, propData = FindPropByEntity(hoveredEntity)
                if isPropFound then
                    displayInfo[#displayInfo + 1] = "[M] to Move Prop  \n"
                    if IsControlJustPressed(0, 244) then
                        MoveProp(hoveredEntity, propData)
                    end
                end
            end

            -- Add current coords info
            displayInfo[#displayInfo + 1] = "Current Coords: " .. currentPosition .. " (H to Copy)  \n"
            ShowTextUI(table.concat(displayInfo))

            -- Copy entity info to clipboard (G key)
            if IsControlJustPressed(0, 47) then
                if hasValidEntity then
                    ShowNotification("Copied to Clipboard", "success")
                    local entityLabel = PropList[GetEntityModel(hoveredEntity)]
                    if not entityLabel then
                        entityLabel = "Not Found"
                    end
                    SendNUIMessage({
                        action = "copytoclipboard",
                        data = string.format("{\"Entity ID\":%s,\"Entity Model\":%s,\"Entity Coords\":%s, \"Entity Label\":%s}", 
                            hoveredEntity, GetEntityModel(hoveredEntity), GetEntityCoords(hoveredEntity), entityLabel)
                    })
                end
            end

            -- Vehicle controls (warp and fix)
            if isVehicle then
                if IsControlJustPressed(0, 311) then
                    TaskWarpPedIntoVehicle(playerPed, hoveredEntity, -1)
                    GiveKeys(hoveredEntity, GetVehicleNumberPlateText(hoveredEntity))
                    ShowNotification("Warped into Vehicle", "success")
                end
                
                if IsControlJustPressed(0, 182) then
                    SetVehicleFixed(hoveredEntity)
                    SetVehicleEngineHealth(hoveredEntity, 1000.0)
                    SetVehicleBodyHealth(hoveredEntity, 1000.0)
                    ShowNotification("Vehicle Fixed", "success")
                end
            end

            -- Copy coords to clipboard (H key)
            if IsControlJustPressed(0, 74) then
                ShowNotification("Copied to Clipboard", "success")
                SendNUIMessage({
                    action = "copytoclipboard",
                    data = string.format("vector3(%s, %s, %s)", currentPosition.x, currentPosition.y, currentPosition.z + 0.2)
                })
            end

            -- Delete entity (E key)
            if IsControlJustPressed(0, 38) then
                if hasValidEntity then
                    TriggerEvent("snipe-menu:client:deleteprop", hoveredEntity)
                end
            end
        end
    end)
end

-- Stop and cleanup delete laser
function stopDeleteLaser()
    if laserObject then
        DeleteObject(laserObject)
    end
    
    currentHeading = 0.0
    currentModel = nil
    currentPosition = nil
    isPlacing = false
    
    for i = 1, 1 do
        Wait(0)
        SetEntityDrawOutline(hoveredEntity, false)
    end
    
    hoveredEntity = nil
    lib.hideTextUI()
end

-- Updates entity highlighting based on camera raycast
function placing2()
    local hit, endCoords, surfaceNormal, materialHash, hitEntity = camPosition(laserObject)
    
    if hit then
        currentPosition = endCoords
        
        if hitEntity then
            if hoveredEntity == nil then
                -- First entity hit
                hoveredEntity = hitEntity
                SetEntityDrawOutline(hitEntity, true)
                SetEntityDrawOutlineColor(0, 255, 0, 1)
                hasValidEntity = true
            elseif hoveredEntity ~= hitEntity then
                -- Changed to new entity
                SetEntityDrawOutline(hoveredEntity, false)
                hoveredEntity = hitEntity
                SetEntityDrawOutline(hitEntity, true)
                SetEntityDrawOutlineColor(0, 255, 0, 1)
                hasValidEntity = true
            end
        else
            if hoveredEntity ~= nil then
                -- No longer hovering entity
                SetEntityDrawOutline(hoveredEntity, false)
                hoveredEntity = nil
                hasValidEntity = false
            else
                hasValidEntity = false
            end
        end
    end
end

-- Finds prop index in PropTable by ID
function FindPropIndexById(propId)
    for index, propData in ipairs(PropTable) do
        if propData.id == propId then
            return index
        end
    end
    return nil
end

-- NUI Callback: Delete prop from UI
RegisterNUICallback("deleteProp", function(data, cb)
    if hasAdminPerms then
        local propIndex = FindPropIndexById(data.selectedPlayer.id)
        
        if not propIndex then
            cb("ok")
            return
        end
        
        TriggerServerEvent("snipe-menu:server:sendLogs", "triggered", 
            Config.Locales.deleteprop_used .. " " .. PropTable[propIndex].model)
        TriggerServerEvent("snipe-menu:server:deleteProp", data.selectedPlayer.id, PropTable[propIndex].coords)
        Wait(500)
        cb("ok")
    else
        TriggerServerEvent("snipe-menu:server:sendLogs", "exploit", Config.Locales.deleteprop_exploited)
        cb("ok")
    end
end)

-- NUI Callback: Teleport to prop
RegisterNUICallback("teleportToProp", function(data, cb)
    if hasAdminPerms then
        local propIndex = FindPropIndexById(data.selectedPlayer.id)
        
        if not propIndex then
            cb("ok")
            return
        end
        
        SetEntityCoords(PlayerPedId(), PropTable[propIndex].coords)
        cb("ok")
    else
        cb("ok")
    end
end)

-- Event: Delete prop (lowercase)
RegisterNetEvent("snipe-menu:client:deleteprop")
AddEventHandler("snipe-menu:client:deleteprop", function(entity)
    if entity then
        if PropTable then
            for _, propData in ipairs(PropTable) do
                if propData.obj == entity then
                    TriggerServerEvent("snipe-menu:server:deleteProp", propData.id, propData.coords)
                end
            end
        end
        DeleteEntityHelper(entity)
    end
end)

-- Event: Delete prop (capitalized - server response)
RegisterNetEvent("snipe-menu:client:deleteProp")
AddEventHandler("snipe-menu:client:deleteProp", function(propId, coords)
    if PropTable[propId] then
        -- Remove from nearbyCurrentProps
        for index, propData in ipairs(nearbyCurrentProps) do
            if propData.obj == PropTable[propId].obj then
                table.remove(nearbyCurrentProps, index)
                break
            end
        end
        
        DeleteEntity(PropTable[propId].obj)
        table.remove(PropTable, propId)
    end
end)
