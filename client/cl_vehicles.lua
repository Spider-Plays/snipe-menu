-- Vehicles Management Client

-- NUI Callback: Toggle Benny's mechanic menu
RegisterNUICallback("toggleBennys", function(data, cb)
    if hasAdminPerms then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            BennyOpen()
            cb("ok")
        else
            ShowNotification(Config.Locales.not_in_vehicle, "error")
            cb("ok")
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.toggle_benny_exploit)
    end
end)

-- NUI Callback: Refuel vehicle
RegisterNUICallback("refuelVehicle", function(data, cb)
    if hasAdminPerms then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            RefuelVehicle(vehicle)
        else
            ShowNotification("You are not in a vehicle", "error")
        end
        cb("ok")
    end
end)

-- NUI Callback: Max mod vehicle
RegisterNUICallback("maxmodvehicle", function(data, cb)
    if hasAdminPerms then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            MaxModVehicle(vehicle)
        else
            ShowNotification("You are not in a vehicle", "error")
        end
        cb("ok")
    end
end)

-- Utility: Get trimmed plate text
function GetPlate(plateText)
    return string.gsub(plateText, "^%s*(.-)%s*$", "%1")
end

-- NUI Callback: Change vehicle plate
RegisterNUICallback("changePlate", function(data, cb)
    if hasAdminPerms then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local currentPlate = GetPlate(GetVehicleNumberPlateText(vehicle))
        
        if vehicle ~= 0 then
            TriggerServerEvent("sp-adminmenu:server:changePlate", currentPlate, string.upper(data.plateNumber))
        else
            ShowNotification("You are not in vehicle", "error")
        end
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.announce_exploit)
    end
end)

-- NUI Callback: Get all vehicles list
RegisterNUICallback("getAllVehicles", function(data, cb)
    local vehicles = GetVehiclesList()
    cb(vehicles)
end)

-- NUI Callback: Give car to player
RegisterNUICallback("givecar", function(data, cb)
    if hasAdminPerms then
        local targetId = data.selectedPlayer.id
        local vehicleModel = data.selectedItem.id
        local coords = GetEntityCoords(PlayerPedId())
        
        if not HasModelLoaded(vehicleModel) then
            RequestModel(vehicleModel)
            while not HasModelLoaded(vehicleModel) do
                Wait(0)
            end
        end
        
        local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z - 5.0, coords.w, true, false)
        NetworkFadeInEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)
        SetEntityAsMissionEntity(vehicle, true, true)
        
        local vehicleType = "car"
        local vehicleData = {}
        vehicleData.plate = GetVehicleNumberPlateText(vehicle)
        vehname = GetVehicleNameFromHash(hash)
        vehicleType = GetVehicleTypeFromHash(hash, veh)
        vehicleData.props = GetVehicleProperties(vehicle)
        
        TriggerServerEvent("sp-adminmenu:server:givecar", tonumber(targetId), vehicleModel, vehicleData, vehicleType)
        DeleteEntity(vehicle)
        DeleteVehicle(vehicle)
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.give_car_exploit)
    end
end)

-- NUI Callback: Spawn car with data
RegisterNUICallback("spawncardata", function(data, cb)
    if hasAdminPerms then
        local vehicleModel = data.selectedPlayer.id
        local override = data.override
        local maxMods = data.maxMods
        local seatValue = data.seatValue
        
        if override ~= "" then
            vehicleModel = override
        end
        
        SpawnCar(vehicleModel, maxMods, seatValue)
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.spawn_car_exploit)
    end
end)

-- Find nearest vehicle to player
function GetNearestVehicle()
    local playerPed = PlayerPedId()
    local vehicles = GetGamePool("CVehicle")
    local nearestDistance = -1
    local nearestVehicle = -1
    local playerCoords = GetEntityCoords(playerPed)
    
    if playerCoords then
        if type(playerCoords) == "table" then
            playerCoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z) or playerCoords
        end
    else
        playerCoords = GetEntityCoords(playerPed)
    end
    
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - playerCoords)
        
        if nearestDistance == -1 or nearestDistance > distance then
            nearestVehicle = vehicles[i]
            nearestDistance = distance
        end
    end
    
    return nearestVehicle, nearestDistance
end

-- NUI Callback: Give keys to player
RegisterNUICallback("givekeys", function(data, cb)
    if hasAdminPerms then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        
        if vehicle ~= 0 then
            GiveKeys(vehicle, GetPlate(GetVehicleNumberPlateText(vehicle)))
        else
            local nearestVehicle, distance = GetNearestVehicle()
            if nearestVehicle ~= 0 and distance < 5.0 then
                GiveKeys(nearestVehicle, GetPlate(GetVehicleNumberPlateText(nearestVehicle)))
            else
                ShowNotification("No Vehicle Found", "error")
            end
        end
        cb("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.spawn_car_exploit)
    end
end)

-- NUI Callback: Get all outside vehicles
RegisterNUICallback("getAllOutsideVehicles", function(data, cb)
    local p = promise.new()
    
    TriggerCallback("sp-adminmenu:server:getOutsideVehicles", function(result)
        p:resolve(result)
    end)
    
    local vehicles = Citizen.Await(p)
    cb(vehicles)
end)

-- NUI Callback: Change vehicle state
RegisterNUICallback("changeVehicleState", function(data, cb)
    if hasAdminPerms then
        TriggerServerEvent("sp-adminmenu:server:changeVehicleState", data.selectedPlayer.name)
        cb("ok")
    end
end)

-- NUI Callback: Add admin car
RegisterNUICallback("addAdminCar", function(data, cb)
    if hasAdminPerms then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local vehicleData = {}
            vehicleData.props = GetVehicleProperties(vehicle)
            
            local vehicleHash = vehicleData.props.model
            local vehicleName = GetVehicleNameFromHash(vehicleHash)
            local vehicleType = GetVehicleTypeFromHash(vehicleHash, vehicle)
            
            if vehicleName then
                TriggerServerEvent("sp-adminmenu:server:addAdminCar", vehicleName, vehicleData, vehicleType)
                cb("ok")
            else
                ShowNotification(Config.Locales.vehicle_not_present, "error")
                cb("ok")
            end
        else
            ShowNotification(Config.Locales.not_in_vehicle, "error")
            cb("ok")
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.admin_car_exploit)
    end
end)

-- Event: Add admin car (command triggered)
RegisterNetEvent("sp-adminmenu:client:addAdminCar", function()
    if hasAdminPerms then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local vehicleData = {}
            vehicleData.props = GetVehicleProperties(vehicle)
            
            local vehicleHash = vehicleData.props.model
            local vehicleName = GetVehicleNameFromHash(vehicleHash)
            local vehicleType = GetVehicleTypeFromHash(vehicleHash, vehicle)
            
            if vehicleName then
                TriggerServerEvent("sp-adminmenu:server:addAdminCar", vehicleName, vehicleData, vehicleType)
                return
            else
                ShowNotification(Config.Locales.vehicle_not_present, "error")
                return
            end
        else
            ShowNotification(Config.Locales.not_in_vehicle, "error")
            return
        end
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", Config.Locales.admin_car_exploit)
    end
end)
