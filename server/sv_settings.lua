-- Settings & Permissions System - Server Side

ModSettings = {}
local_perms = {}
perms = {}
permsLoaded = false

function table_deepclone(tbl)
    local clone = table.clone(tbl)

    for key, value in pairs(clone) do
        if type(value) == "table" then
            clone[key] = table_deepclone(value)
        end
    end

    return clone
end

function tableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    Citizen.Wait(100)

    -- Load mod settings from database
    local modSettingsData = MySQL.Sync.fetchAll("SELECT * FROM snipe_menu_modsettings")
    for _, row in ipairs(modSettingsData) do
        ModSettings[row.role] = json.decode(row.settings)
    end

    -- Load permissions from database
    local permsData = MySQL.Sync.fetchAll("SELECT * FROM snipe_menu_perms")
    for _, row in ipairs(permsData) do
        local_perms[row.identifier] = {
            name = row.name,
            perms = json.decode(row.perms)
        }
    end

    -- Merge config permissions
    for identifier, permData in pairs(Config.Permissions) do
        perms[identifier] = permData
    end

    -- Merge local permissions
    for identifier, permData in pairs(local_perms) do
        perms[identifier] = permData.perms
    end

    permsLoaded = true
end)

CreateCallback("snipe-menu:server:getAllTable", function(source, callback)
    callback(ModSettings)
end)

CreateCallback("snipe-menu:server:getRoleWisePanels", function(source, callback, roles)
    local panels = {}

    if type(roles) == "table" then
        for _, roleName in pairs(roles) do
            for settingLabel, settingPanels in pairs(ModSettings) do
                local roleLabel = Config.GodRoles[roleName]
                if settingLabel == roleLabel then
                    for _, panel in pairs(settingPanels) do
                        if not tableContains(panels, panel) then
                            table.insert(panels, panel)
                        end
                    end
                end
            end
        end
    else
        for settingLabel, settingPanels in pairs(ModSettings) do
            local roleLabel = Config.GodRoles[roles]
            if settingLabel == roleLabel then
                panels = settingPanels
            end
        end
    end

    callback(panels)
end)

CreateCallback("snipe-menu:server:getRoleWisePanelsWithLabel", function(source, callback, roleLabel)
    for settingLabel, settingPanels in pairs(ModSettings) do
        if settingLabel == roleLabel then
            callback(settingPanels)
            return
        end
    end
    callback({})
end)

RegisterServerEvent("snipe-menu:server:saveModeratorCommands", function(settings, roleLabel)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: snipe-menu:server:saveModeratorCommands")
        DropPlayer(playerId, "Exploit detected")
        return
    end

    ModSettings[roleLabel] = settings

    MySQL.Async.execute(
        "INSERT INTO snipe_menu_modsettings (role, settings) VALUES (@role, @settings) ON DUPLICATE KEY UPDATE settings = @settings",
        {
            ["@role"] = roleLabel,
            ["@settings"] = json.encode(settings)
        }
    )
end)

RegisterNetEvent("snipe-menu:server:givePerms", function(targetId, permission)
    local playerId = source

    if not onlineAdmins[playerId] then
        return
    end

    -- Only god role can give permissions
    local adminRole = exports["snipe-menu"]:GetAdminRoleName(playerId)
    if adminRole ~= "god" then
        return
    end

    -- Confirm with admin
    local confirmed = lib.callback.await("snipe-menu:server:confirmGivePerms", playerId, targetId, permission, GetPlayerName(tonumber(targetId)))
    if not confirmed then
        return
    end

    local targetIdentifier = playerIdToIdentifier[tonumber(targetId)]
    if not targetIdentifier then
        targetIdentifier = GetPlayerFrameworkIdentifier(tonumber(targetId))
    end

    -- Create entry if doesn't exist
    if not local_perms[targetIdentifier] then
        local_perms[targetIdentifier] = {
            name = GetPlayerName(tonumber(targetId)),
            perms = {},
            id = targetId
        }
    end

    -- Add permission if not already present
    if not tableContains(local_perms[targetIdentifier].perms, permission) then
        table.insert(local_perms[targetIdentifier].perms, permission)
    end

    perms[targetIdentifier] = local_perms[targetIdentifier].perms

    -- Save to database
    MySQL.Async.execute(
        "INSERT INTO snipe_menu_perms (identifier, name, perms) VALUES (@identifier, @name, @perms) ON DUPLICATE KEY UPDATE perms = @perms",
        {
            ["@identifier"] = targetIdentifier,
            ["@name"] = GetPlayerName(tonumber(targetId)),
            ["@perms"] = json.encode(perms[targetIdentifier])
        }
    )

    TriggerClientEvent("snipe-menu:client:resetPermissions", tonumber(targetId))
    ResetDutyPermsTable(tonumber(targetId))
end)

CreateCallback("snipe-menu:server:getAdmins", function(source, callback)
    if not onlineAdmins[source] then
        SendLogs(source, "exploit", "Exploit detected: snipe-menu:server:getAdmins")
        DropPlayer(source, "Exploit detected")
        return
    end

    local adminList = {}
    for identifier, permData in pairs(local_perms) do
        table.insert(adminList, {
            id = identifier,
            name = permData.name
        })
    end

    callback(adminList)
end)

RegisterNetEvent("snipe-menu:server:removeRoles", function(identifier)
    if not onlineAdmins[source] then
        return
    end

    local targetPlayerId = local_perms[identifier] and local_perms[identifier].id or nil

    local_perms[identifier] = nil
    perms[identifier] = nil

    MySQL.Async.execute("DELETE FROM snipe_menu_perms WHERE identifier = @identifier", {
        ["@identifier"] = identifier
    })

    if targetPlayerId then
        TriggerClientEvent("snipe-menu:client:removeAllPermissions", tonumber(targetPlayerId))
        ResetDutyPermsTable(tonumber(targetPlayerId))
    end
end)
