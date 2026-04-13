-- Favourite Locations Client - NUI Callbacks

RegisterNUICallback("getSavedLocations", function(data, callback)
    local locations = {}

    for id, locationData in pairs(Config.SavedLocations) do
        table.insert(locations, {
            id = id,
            name = locationData.label
        })
    end

    callback(locations)
end)

RegisterNUICallback("sendToSavedLocation", function(data, callback)
    if not hasAdminPerms then return end

    local locationId = data.selectedPlayer.id
    local coords = Config.SavedLocations[locationId].coords

    SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, coords.z)

    callback("ok")
end)
