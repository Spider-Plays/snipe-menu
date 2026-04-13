-- Settings & Permissions Client - NUI Callbacks

function TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

RegisterNUICallback("saveModeratorCommands", function(data, callback)
    if hasAdminPerms then
        TriggerServerEvent("sp-adminmenu:server:saveModeratorCommands", data.selectedValues, data.role)
        callback("ok")
    else
        TriggerServerEvent("sp-adminmenu:server:sendLogs", "exploit", "Tried to save moderator commands")
    end
end)

RegisterNUICallback("getRoleWisePanels", function(data, callback)
    local roleLabel = data.role

    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getRoleWisePanelsWithLabel", function(result)
        p:resolve(result)
    end, roleLabel)

    panelsToDisplay = Citizen.Await(p)
    callback(panelsToDisplay)
end)

RegisterNUICallback("getAllRoles", function(data, callback)
    local roles = {}

    for _, roleLabel in pairs(Config.GodRoles) do
        if roleLabel ~= "God" and not TableContains(roles, roleLabel) then
            table.insert(roles, roleLabel)
        end
    end

    callback(roles)
end)

RegisterNUICallback("getRoles", function(data, callback)
    local roles = {}

    for roleId, roleLabel in pairs(Config.GodRoles) do
        table.insert(roles, {
            id = roleId,
            name = roleLabel
        })
    end

    callback(roles)
end)

RegisterNUICallback("givePerms", function(data, callback)
    local targetId = data.selectedPlayer.id
    local roleId = data.selectedItem.id

    TriggerServerEvent("sp-adminmenu:server:givePerms", targetId, roleId)
    callback("ok")
end)

RegisterNUICallback("getAdmins", function(data, callback)
    local p = promise.new()

    TriggerCallback("sp-adminmenu:server:getAdmins", function(result)
        p:resolve(result)
    end)

    local admins = Citizen.Await(p)
    callback(admins)
end)

RegisterNUICallback("removeRoles", function(data, callback)
    TriggerServerEvent("sp-adminmenu:server:removeRoles", data.selectedValue.id)
    callback("ok")
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= "sp-adminmenu" then return end

    Wait(1000)
    TriggerServerEvent("sp-adminmenu:server:playerLoaded")

    -- Load prop tables
    local p = promise.new()
    TriggerCallback("sp-adminmenu:server:getTables", function(result)
        p:resolve(result)
    end)
    PropTable = Citizen.Await(p)
    isSpawned = true

    -- Load admin permissions if not using admin duty system
    if not Config.AdminDuty then
        local permPromise = promise.new()
        TriggerCallback("sp-adminmenu:server:getAdminPerms", function(result)
            permPromise:resolve(result)
        end)

        local perms = Citizen.Await(permPromise)
        hasAdminPerms = perms[1]
        userAccesses = perms[2]
        userRole = perms[3] or "God"
        isGod = perms[4]

        TriggerEvent("sp-adminmenu:client:addkeymapping", hasAdminPerms)
    end
end)

lib.callback.register("sp-adminmenu:server:confirmGivePerms", function(targetId, roleId, playerName)
    local result = lib.alertDialog({
        header = "Admin Confirmation",
        content = "Are you sure you want to give " .. playerName .. "(" .. targetId .. ") the role of " .. roleId .. "?",
        centered = true,
        cancel = true,
        labels = {
            confirm = "Confirm",
            cancel = "Cancel"
        }
    })

    return result == "confirm"
end)
