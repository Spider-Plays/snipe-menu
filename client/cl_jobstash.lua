local DEFAULT_PROP_MODEL = "v_res_tre_storagebox"
isSelecting = nil
local isPlacing = false
PropTable = {}
local laserObject = nil
local currentHeading = 0.0
local currentPosition = nil
isSpawned = true
local hoveredEntity = nil
local autoSnap = nil
local highlightColor = { r = 0, g = 255, b = 0, a = 200 }
local hasEntityHit = false
local jobLocal = nil
local sizeLocal = nil
local slotsLocal = nil
local isJobLocal = nil
local isGangLocal = nil
local isMovingProp = false
nearbyCurrentProps = {}

function camPosition(entity)
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)
    
    local pitchRad = (math.pi / 180) * camRot.x
    local yawRad = (math.pi / 180) * camRot.z
    
    local absCosPitch = math.abs(math.cos(pitchRad))
    
    local direction = {}
    direction.x = -math.sin(yawRad) * absCosPitch
    direction.y = math.cos(yawRad) * absCosPitch
    direction.z = math.sin(pitchRad)
    
    local rayStart = {
        camCoords.x + direction.x,
        camCoords.y + direction.y,
        camCoords.z + direction.z
    }
    
    local rayHandle = StartShapeTestSweptSphere(
        camCoords.x + direction.x,
        camCoords.y + direction.y,
        camCoords.z + direction.z,
        camCoords.x + (direction.x * 50),
        camCoords.y + (direction.y * 50),
        camCoords.z + (direction.z * 50),
        0.2,
        339,
        entity,
        7
    )
    
    return GetShapeTestResultIncludingMaterial(rayHandle)
end

function stopPlacing()
    if laserObject then
        DeleteObject(laserObject)
    end
    
    currentHeading = 0.0
    isSelecting = nil
    currentPosition = nil
    isPlacing = false
    
    SendNUIMessage({ action = "hideGizmoObject" })
    SendNUIMessage({ action = "showGizmoObject", data = {} })
    SetNuiFocus(false, false)
    
    job = nil
    size = nil
    slots = nil
    isJob = nil
    isGang = nil
end

function rotationToDirection(rotation)
    local rotRad = vec3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    
    local direction = vec3(
        -math.sin(rotRad.z) * math.abs(math.cos(rotRad.x)),
        math.cos(rotRad.z) * math.abs(math.cos(rotRad.x)),
        math.sin(rotRad.x)
    )
    
    return direction
end

local superJumpEnabled = false

function StartPlacingThread(model, jobName, stashSize, stashSlots, isForJob, isForGang)
    local playerPed = PlayerPedId()
    isSelecting = model
    
    local camDistance = 10
    local camRot = GetFinalRenderedCamRot()
    local camCoords = GetFinalRenderedCamCoord()
    local direction = rotationToDirection(camRot)
    
    jobLocal = jobName
    sizeLocal = stashSize
    slotsLocal = stashSlots
    isJobLocal = isForJob
    isGangLocal = isForGang
    
    local spawnPos = vec3(
        camCoords.x + (direction.x * camDistance),
        camCoords.y + (direction.y * camDistance),
        camCoords.z + (direction.z * camDistance)
    )
    currentPosition = spawnPos
    
    laserObject = CreateObject(GetHashKey(model), currentPosition.x, currentPosition.y, currentPosition.z)
    Wait(50)
    
    SetEntityAlpha(laserObject, 100)
    FreezeEntityPosition(laserObject, true)
    GizmoToggle(laserObject)
    Wait(50)
    
    placeFocus = true
end

local propMovingData = nil

function PlaceObject(rotation, position, heading)
    if isMovingProp then
        TriggerServerEvent("sp-adminmenu:server:moveObject", rotation, heading, position, propMovingData)
        isMovingProp = false
        propMovingData = nil
    else
        PutJobStash(isSelecting, rotation, heading, jobLocal, sizeLocal, slotsLocal, isJobLocal, isGangLocal, position)
    end
end

function ResetObject()
    if isMovingProp then
        DeleteObject(propMovingData.obj)
        propMovingData.obj = nil
        isMovingProp = false
    else
        stopPlacing()
    end
end

function MoveProp(entity, propData)
    isMovingProp = true
    propMovingData = propData
    GizmoToggle(entity)
end

function PutJobStash(model, rotation, heading, jobName, stashSize, stashSlots, stashLabel, isForJob, isForGang, position)
    canPlace = true
    
    if laserObject then
        DeleteObject(laserObject)
    end
    
    isSelecting = nil
    currentPosition = nil
    
    local stashName = ""
    if jobName ~= nil then
        stashName = "jobstash_" .. jobName .. "_" .. math.random(1, 1000)
    end
    
    isPlacing = false
    
    if canPlace then
        TriggerServerEvent("sp-adminmenu:server:putNewJobStash", 
            rotation, model, heading, jobName, stashSize, stashSlots, stashName, 
            stashLabel, isForJob, isForGang)
    end
end

RegisterNetEvent("sp-adminmenu:client:addNewJobStash", function(propData)
    PropTable[#PropTable + 1] = propData
end)

RegisterNetEvent("sp-adminmenu:client:updateObject", function(propId, coords, heading, rotation)
    for _, propData in pairs(PropTable) do
        if propData.id == propId then
            propData.coords = coords
            propData.heading = heading
            propData.rotation = rotation
            
            if propData.obj then
                DeleteEntity(propData.obj)
                propData.obj = nil
            end
            break
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    if PropTable then
        for _, propData in pairs(PropTable) do
            DeleteEntity(propData.obj)
            propData.obj = nil
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        
        if isSpawned and PropTable then
            inRange = false
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, propData in ipairs(PropTable) do
                local distance = #(playerCoords - propData.coords)
                
                if distance <= 150.0 then
                    if propData.obj == nil then
                        local obj = CreateObject(
                            GetHashKey(propData.model),
                            propData.coords.x,
                            propData.coords.y,
                            propData.coords.z,
                            false
                        )
                        
                        SetEntityCoords(obj, propData.coords.x, propData.coords.y, propData.coords.z, false, false, false, false)
                        SetEntityHeading(obj, propData.heading)
                        FreezeEntityPosition(obj, true)
                        
                        if propData.rotation then
                            SetEntityRotation(obj, propData.rotation.x, propData.rotation.y, propData.rotation.z)
                        end
                        
                        propData.obj = obj
                        SetTargetExports(propData.obj, propData.job, propData.size, propData.slots, propData.stashName, propData.isJob, propData.isGang)
                        
                        nearbyCurrentProps[#nearbyCurrentProps + 1] = propData
                    end
                else
                    if propData.obj then
                        DeleteEntity(propData.obj)
                        
                        for index, nearbyProp in ipairs(nearbyCurrentProps) do
                            if nearbyProp.obj == propData.obj then
                                table.remove(nearbyCurrentProps, index)
                                break
                            end
                        end
                        
                        propData.obj = nil
                    end
                end
            end
        end
        
        if not inRange then
            Citizen.Wait(500)
        end
    end
end)

RegisterNUICallback("setJobStash", function(data, cb)
    if hasAdminPerms then
        local jobId = data.selectedValue.id
        local stashSize = tonumber(data.size) * 1000
        local stashSlots = tonumber(data.slot)
        
        if data.prop_override ~= "" then
            DEFAULT_PROP_MODEL = data.prop_override
        end
        
        if not IsModelInCdimage(GetHashKey(DEFAULT_PROP_MODEL)) then
            ShowNotification(Config.Locales.invalid_prop, "error")
            cb("ok")
            return
        end
        
        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        cb("ok")
        
        StartPlacingThread(DEFAULT_PROP_MODEL, jobId, stashSize, stashSlots, true, false)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.job_stash_exploit)
    end
end)

RegisterNUICallback("setGangStash", function(data, cb)
    if hasAdminPerms then
        local gangId = data.selectedValue.id
        local stashSize = tonumber(data.size) * 1000
        local stashSlots = tonumber(data.slot)
        
        if data.prop_override ~= "" then
            DEFAULT_PROP_MODEL = data.prop_override
        end
        
        if not IsModelInCdimage(GetHashKey(DEFAULT_PROP_MODEL)) then
            ShowNotification(Config.Locales.invalid_prop, "error")
            cb("ok")
            return
        end
        
        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        cb("ok")
        
        StartPlacingThread(DEFAULT_PROP_MODEL, gangId, stashSize, stashSlots, false, true)
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.job_stash_exploit)
    end
end)

RegisterNUICallback("spawnObject", function(data, cb)
    if hasAdminPerms then
        TriggerEvent("sp-adminmenu:client:forceCloseAdminMenu")
        cb("ok")
        
        if IsModelInCdimage(data.objectName) then
            StartPlacingThread(data.objectName, nil, nil, nil, false, false)
        else
            ShowNotification("Invalid Model", "error")
            cb("ok")
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.job_stash_exploit)
    end
end)

RegisterNUICallback("getindividualjobs", function(data, cb)
    local jobs = GetJobsWithNameAndLabel()
    cb(jobs)
end)

RegisterNUICallback("getIndividualGangs", function(data, cb)
    local gangs = GetGangsWithNameAndLabel()
    cb(gangs)
end)

RegisterNUICallback("getProps", function(data, cb)
    local propsList = {}
    
    for _, propData in pairs(PropTable) do
        if propData.isJob then
            propsList[#propsList + 1] = {
                id = propData.id,
                name = "Job Stash " .. propData.job
            }
        elseif propData.isGang then
            propsList[#propsList + 1] = {
                id = propData.id,
                name = "Gang Stash " .. propData.job
            }
        else
            local streetHash = GetStreetNameAtCoord(propData.coords.x, propData.coords.y, propData.coords.z)
            
            propsList[#propsList + 1] = {
                id = propData.id,
                name = "Object on " .. GetStreetNameFromHashKey(streetHash)
            }
        end
    end
    
    cb(propsList)
end)

RegisterKeyMapping("gizmoToggleSelection", "Toggles the gizmo to lock for the current entity", "MOUSE_BUTTON", "MOUSE_RIGHT")
RegisterKeyMapping("+gizmoSelect", "Selects the currently highlighted gizmo", "MOUSE_BUTTON", "MOUSE_LEFT")
RegisterKeyMapping("+gizmoTranslation", "Sets mode of the gizmo to translation", "keyboard", "T")
RegisterKeyMapping("+gizmoRotation", "Sets mode for the gizmo to rotation", "keyboard", "R")
RegisterKeyMapping("+gizmoLocal", "Sets gizmo to be local to the entity instead of world", "keyboard", "L")
