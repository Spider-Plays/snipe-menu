-- Job Stash / Props System - Server Side

ContainerTable = {}
wrongName = false

Citizen.CreateThread(function()
    Citizen.Wait(100)

    local resourceName = GetCurrentResourceName()
    if resourceName == "snipe-menu" then
        local stashData = MySQL.Sync.fetchAll("SELECT * FROM snipe_menu_stashesprop")

        for _, stash in ipairs(stashData) do
            local coordsData = json.decode(stash.coords)
            stash.coords = vector3(coordsData.x, coordsData.y, coordsData.z)

            local rotationData = json.decode(stash.rotation)
            stash.rotation = rotationData or { x = 0, y = 0, z = 0 }

            stash.isJob = (stash.isJob == 1)
            stash.isGang = (stash.isGang == 1)

            table.insert(ContainerTable, stash)
        end
    else
        print("^1[Resource Rename] ^0You have renamed the resource. No data will be loaded. Please rename it back to ^snipe-menu^0!")
        wrongName = true
    end
end)

CreateCallback("snipe-menu:server:getTables", function(source, callback)
    callback(ContainerTable)
end)

RegisterNetEvent("snipe-menu:server:moveObject", function(coords, heading, rotation, stashData)
    local playerId = source

    if playerId ~= 0 and onlineAdmins[playerId] then
        MySQL.Async.execute(
            "UPDATE snipe_menu_stashesprop SET coords = @coords, heading = @heading, rotation = @rotation WHERE id = @id",
            {
                ["@coords"] = json.encode(coords),
                ["@heading"] = heading,
                ["@rotation"] = json.encode(rotation),
                ["@id"] = stashData.id
            },
            function(affectedRows)
                if affectedRows > 0 then
                    TriggerClientEvent("snipe-menu:client:updateObject", -1, stashData.id, coords, heading, rotation)
                end
            end
        )
    end
end)

RegisterServerEvent("snipe-menu:server:putNewJobStash")
AddEventHandler("snipe-menu:server:putNewJobStash", function(coords, model, heading, job, size, slots, stashName, isJob, isGang, rotation)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: snipe-menu:server:putNewJobStash")
        DropPlayer(playerId, "Exploit detected")
        return
    end

    local newStash = {
        coords = coords,
        model = model,
        heading = heading,
        rotation = rotation
    }

    if isJob or isGang then
        newStash.job = job
        newStash.size = size
        newStash.slots = slots
        newStash.stashName = stashName
    end

    if isJob then
        newStash.isJob = isJob
    elseif isGang then
        newStash.isGang = isGang
    end

    table.insert(ContainerTable, newStash)

    MySQL.Sync.execute(
        "INSERT INTO snipe_menu_stashesprop (stashName, model, heading, job, size, slots, coords, rotation, isJob, isGang) VALUES (@stashName, @model, @heading, @job, @size, @slots, @coords, @rotation, @isJob, @isGang)",
        {
            ["@stashName"] = stashName,
            ["@model"] = model,
            ["@heading"] = heading,
            ["@job"] = job,
            ["@size"] = size,
            ["@slots"] = slots,
            ["@coords"] = json.encode(coords),
            ["@rotation"] = json.encode(rotation),
            ["@isJob"] = isJob,
            ["@isGang"] = isGang
        }
    )

    local sizeInKg = size / 1000

    if isJob then
        SendLogs(playerId, "triggered", Config.Locales.job_stash_created .. stashName .. " ( for Job: " .. job .. ")" .. " (" .. sizeInKg .. ")" .. " (" .. slots .. ")" .. "at (" .. coords.x .. ", " .. coords.y .. ", " .. coords.z .. ")")
        RegisterStash(stashName, slots, size)
    elseif isGang then
        SendLogs(playerId, "triggered", Config.Locales.job_stash_created .. stashName .. " ( for Gang: " .. job .. ")" .. " (" .. sizeInKg .. ")" .. " (" .. slots .. ")" .. "at (" .. coords.x .. ", " .. coords.y .. ", " .. coords.z .. ")")
        RegisterStash(stashName, slots, size)
    else
        SendLogs(playerId, "triggered", Config.Locales.prop_created .. " (" .. model .. ")" .. " at: (" .. coords.x .. ", " .. coords.y .. ", " .. coords.z .. ")")
    end

    newStash.id = MySQL.Sync.fetchScalar("SELECT id FROM snipe_menu_stashesprop ORDER BY id DESC LIMIT 1")
    TriggerClientEvent("snipe-menu:client:addNewJobStash", -1, newStash)
end)

RegisterServerEvent("snipe-menu:server:deleteProp")
AddEventHandler("snipe-menu:server:deleteProp", function(stashId, stashCoords)
    local playerId = source

    if not onlineAdmins[playerId] then
        SendLogs(playerId, "exploit", "Exploit detected: snipe-menu:server:deleteProp")
        DropPlayer(playerId, "Exploit detected")
        return
    end

    for index, stash in ipairs(ContainerTable) do
        if stash.coords == stashCoords then
            table.remove(ContainerTable, index)
            MySQL.Async.execute("DELETE FROM snipe_menu_stashesprop WHERE id = @id", { ["@id"] = stashId })
            TriggerClientEvent("snipe-menu:client:deleteProp", -1, index)
            return
        end
    end
end)

CreateThread(function()
    Wait(1000)

    for _, stash in pairs(ContainerTable) do
        if stash.isJob or stash.isGang then
            RegisterStash(stash.stashName, stash.slots, stash.size)
        end
    end
end)
