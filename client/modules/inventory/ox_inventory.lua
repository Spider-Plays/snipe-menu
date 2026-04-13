if Config.Inventory ~= "ox" then return end

function GetItemsWithNameAndLabel()
    local returnData = {}
    for k, v in pairs(exports.ox_inventory:Items()) do
        if type(v) == "table" then
            if v.label then
                returnData[#returnData + 1] = {
                    id = k,
                    name = v.label or "No Label Item",
                }
            end
        end
    end
    return returnData
end

function OpenStash(stashName, owner)
    if owner ~= "" then
        if not exports.ox_inventory:openInventory('stash', { id = stashName, owner = owner }) then
            TriggerServerEvent("sp-adminmenu:server:registerStash", stashName)
            exports.ox_inventory:openInventory('stash', { id = stashName, owner = owner })
        end
    else
        if not exports.ox_inventory:openInventory('stash', stashName) then
            TriggerServerEvent("sp-adminmenu:server:registerStash", stashName)
            exports.ox_inventory:openInventory('stash', stashName)
        end
    end
end

local isInvOpen = false
local spawnedVehicle = nil
function OpenTrunk(vehicle, plate)
    local model = lib.callback.await('sp-adminmenu:server:getCarModel', false, plate) or "sultan"
    local myCoords = GetEntityCoords(PlayerPedId())
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(100)
    end
    spawnedVehicle = CreateVehicle(model, myCoords.x, myCoords.y, myCoords.z - 10.0, 0.0, true, false)
    -- SetEntityAlpha(spawnedVehicle, 0)
    SetVehicleNumberPlateText(spawnedVehicle, plate)
    FreezeEntityPosition(spawnedVehicle, true)
    SetEntityCoords(spawnedVehicle, myCoords.x, myCoords.y, myCoords.z - 10.0)
    Wait(1000)
    TriggerServerEvent("sp-adminmenu:server:forceOpenOxInventory", "trunk", { plate = plate , netid = NetworkGetNetworkIdFromEntity(spawnedVehicle)})
    isInvOpen = true
end

function OpenGlovebox(plate)
    local model = lib.callback.await('sp-adminmenu:server:getCarModel', false, plate) or "sultan"
    local myCoords = GetEntityCoords(PlayerPedId())
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(100)
    end
    spawnedVehicle = CreateVehicle(model, myCoords.x, myCoords.y, myCoords.z - 10.0, 0.0, true, false)
    -- SetEntityAlpha(spawnedVehicle, 0)
    SetVehicleNumberPlateText(spawnedVehicle, plate)
    FreezeEntityPosition(spawnedVehicle, true)
    SetEntityCoords(spawnedVehicle, myCoords.x, myCoords.y, myCoords.z - 10.0)
    Wait(1000)
    TriggerServerEvent("sp-adminmenu:server:forceOpenOxInventory", "glovebox", { plate = plate , netid = NetworkGetNetworkIdFromEntity(spawnedVehicle)})
    isInvOpen = true
end

RegisterNetEvent('ox_inventory:closeInventory', function()
	if isInvOpen and spawnedVehicle then
        isInvOpen = false
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
    end
end)

function openJobStash(data)
    exports.ox_inventory:openInventory('stash', data.jobStashName)

end

RegisterNetEvent("sp-adminmenu:client:openinventory", function(otherPlayer)
    TriggerServerEvent("sp-adminmenu:server:openInventory", otherPlayer)
end)