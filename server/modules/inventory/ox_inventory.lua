if Config.Inventory ~= "ox" then return end

RegisterNetEvent("snipe-menu:server:forceOpenOxInventory", function(invtype, plate)
    local src = source
    if not onlineAdmins[src] then 
        SendLogs(src, "exploit", "Exploit detected: snipe-menu:server:forceOpenOxInventory")
        DropPlayer(src, "Exploit detected")
        return
    end
    exports.ox_inventory:forceOpenInventory(src, invtype, plate)
end)

function RegisterStash(jobStashName, slots, size) -- only for ox
    exports.ox_inventory:RegisterStash(jobStashName, jobStashName, slots, size, false)
end


function GetAllStashes()
    local result = MySQL.query.await('SELECT name FROM ox_inventory')
    local returnData = {}
    if result ~= nil then
        for k, v in pairs(result) do
            returnData[#returnData + 1] = {
                id = k,
                name = v.name,
            }
        end
        return returnData
    else
        return nil
    end
end

function GiveItemToPlayer(playerId, giveItem, giveAmount, src)
    local success, response = exports.ox_inventory:AddItem(playerId, giveItem, giveAmount)
    if not success then
        -- if no slots are available, the value will be "inventory_full"
        return print(response)
    end
end

function ClearInventory(otherPlayerId)
    exports.ox_inventory:ClearInventory(otherPlayerId)
end

function GetAllOwnedVehicles()
    local query = 'SELECT plate FROM owned_vehicles where trunk != "NULL" OR glovebox != "NULL"'
    if Config.Framework == "qb" or Config.Framework == "qbx" then
        query = 'SELECT plate FROM player_vehicles where trunk != "NULL" OR glovebox != "NULL"'
    end
    local result = MySQL.query.await(query)
    local returnData = {}
    if result ~= nil then
        for k, v in pairs(result) do
            returnData[#returnData + 1] = {
                id = k,
                name = v.plate,
            }
        end
        return returnData
    else
        return nil
    end
end

lib.callback.register('snipe-menu:server:getCarModel', function(source, plate)
    local query = 'SELECT model FROM owned_vehicles WHERE plate = ? LIMIT 1'
    if Config.Framework == "qb" or Config.Framework == "qbx" then
        query = 'SELECT vehicle FROM player_vehicles WHERE plate = ? LIMIT 1'
    end
    local model = MySQL.Sync.fetchScalar(query, {plate})
    return model
end)