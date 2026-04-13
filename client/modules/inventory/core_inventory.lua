if Config.Inventory ~= "core"  then return end


function GetItemsWithNameAndLabel()
    local returnData = {}
    if Config.Framework == "qb" then
        for k, v in pairs(QBCore.Shared.Items) do
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
    elseif Config.Framework == "esx" then
       local p = promise.new()
        TriggerCallback("sp-adminmenu:server:getAllItems", function(result)
            p:resolve(result)
        end)
        local Items = Citizen.Await(p)
        local returnData = {}
        for k, v in pairs(Items) do
            returnData[#returnData + 1] = {
                id = k,
                name = v.label or "No Label Item",
            }
        end
        return returnData
    end
end

function OpenStash(stashName, owner)
    TriggerServerEvent("sp-adminmenu:server:openStash", stashName)
end

-- no information about trunk in core_inventory
function OpenTrunk(vehicle, plate)
end

-- no information about glovebox in core_inventory
function OpenGlovebox(plate)
end

function openJobStash(data)
    TriggerServerEvent("sp-adminmenu:server:openStash", data.jobStashName)
end

RegisterNetEvent("sp-adminmenu:client:openinventory", function(otherPlayer)
    TriggerServerEvent('core_inventory:server:openInventory', otherPlayer, 'otherplayer', nil, nil, false)
end)