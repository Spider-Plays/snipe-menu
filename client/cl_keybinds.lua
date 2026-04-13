RegisterCommand("noclip", function()
    if hasAdminPerms then
        local hasNoclipPerms = false
        
        if isGod then hasNoclipPerms = true end
        if not hasNoclipPerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "NoClip" then
                    hasNoclipPerms = true
                    break
                end
            end
        end
        if hasNoclipPerms then
            ToggleNoClip()
        end
    end
end)





RegisterCommand("+deletelaser", function()
    if devMode and hasAdminPerms then
        DeleteLaser()
    end
end)

RegisterCommand("-deletelaser", function()
    if devMode and hasAdminPerms then
        stopDeleteLaser()
    end
end)

RegisterCommand("tpm", function()
    if hasAdminPerms then
        local hasNoclipPerms = false
        
        if isGod then hasNoclipPerms = true end
        if not hasNoclipPerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Teleport Marker" then
                    hasNoclipPerms = true
                    break
                end
            end
        end
        if hasNoclipPerms then
            TriggerEvent("sp-adminmenu:client:teleportMarker")
        end
    end        
end)

RegisterCommand("fixvehiclekeybind", function()
    -- if hasAdminPerms then
    --     TriggerEvent("sp-adminmenu:client:FixVehicle")
    --     ShowNotification("[Admin Menu] Vehicle has been fixed", "success")
    -- end
    if hasAdminPerms then
        local hasFixVehiclePerms = false
        
        if isGod then hasFixVehiclePerms = true end
        if not hasFixVehiclePerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Fix Vehicle" then
                    hasFixVehiclePerms = true
                    break
                end
            end
        end
        if hasFixVehiclePerms then
            TriggerEvent("sp-adminmenu:client:FixVehicle")
            ShowNotification("[Admin Menu] Vehicle has been fixed", "success")
        end
    end
end)

RegisterCommand("admincarkeybind", function()
    if hasAdminPerms then
        local hasAdminCarPerms = false
        
        if isGod then hasAdminCarPerms = true end
        if not hasAdminCarPerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Admin Car" then
                    hasAdminCarPerms = true
                    break
                end
            end
        end
        if hasAdminCarPerms then
            TriggerEvent("sp-adminmenu:client:addAdminCar")
        end
    end
end)


RegisterCommand("godmodekeybind", function()
    if hasAdminPerms then
        local hasGodModePerms = false
        
        if isGod then hasGodModePerms = true end
        if not hasGodModePerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "God Mode" then
                    hasGodModePerms = true
                    break
                end
            end
        end
        if hasGodModePerms then
            TriggerEvent("sp-adminmenu:client:godMode")
        end
    end
end)


RegisterCommand("invisiblekeybind", function()
    if hasAdminPerms then
        local hasInvisiblePerms = false
        
        if isGod then hasInvisiblePerms = true end
        if not hasInvisiblePerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Invisible" then
                    hasInvisiblePerms = true
                    break
                end
            end
        end
        if hasInvisiblePerms then
            TriggerEvent("sp-adminmenu:client:invisibleEffect")
        end
    end
end)

RegisterCommand("toggleblipskeybind", function()
    if hasAdminPerms then
        local hasToggleBlipsPerms = false
        
        if isGod then hasToggleBlipsPerms = true end
        if not hasToggleBlipsPerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Toggle Blips" then
                    hasToggleBlipsPerms = true
                    break
                end
            end
        end
        if hasToggleBlipsPerms then
            ToggleBlips()
        end
    end
end)

RegisterCommand("togglenameskeybind", function()
    if hasAdminPerms then
        local hasToggleNamesPerms = false
        
        if isGod then hasToggleNamesPerms = true end
        if not hasToggleNamesPerms then
            local p = promise.new()
            TriggerCallback("sp-adminmenu:server:getRoleWisePanels", function(result)
                p:resolve(result)
            end, userAccesses)
            panelsToDisplay = Citizen.Await(p)

            for k,v in pairs(panelsToDisplay) do
                if v == "Toggle Names" then
                    hasToggleNamesPerms = true
                    break
                end
            end
        end
        if hasToggleNamesPerms then
            TriggerEvent("sp-adminmenu:client:toggleNames")
        end
    end
end)

if Config.EnableReports then
    RegisterCommand("report", function()
        OpenReports()
    end)
    
    TriggerEvent('chat:addSuggestion', '/togglereports', "Toggle Report Notifications (Admin Only)")
    RegisterCommand("togglereports", function()
        if hasAdminPerms then
            TriggerServerEvent("sp-adminmenu:server:toggleReports")
        end
    end)
end

RegisterCommand(Config.CommandName, function()
    OpenAdminMenu()
end)

TriggerEvent("chat:removeSuggestion", "/noclip")
TriggerEvent("chat:removeSuggestion", "/teleporttomarker")
TriggerEvent("chat:removeSuggestion", "/fixvehiclekeybind")
TriggerEvent("chat:removeSuggestion", "/+deletelaser")
TriggerEvent("chat:removeSuggestion", "/-deletelaser")
TriggerEvent("chat:removeSuggestion", "/admincarkeybind")
TriggerEvent("chat:removeSuggestion", "/godmodekeybind")
TriggerEvent("chat:removeSuggestion", "/invisiblekeybind")
TriggerEvent("chat:removeSuggestion", "/toggleblipskeybind")
TriggerEvent("chat:removeSuggestion", "/togglenameskeybind")

RegisterNetEvent("sp-adminmenu:client:addkeymapping", function()
    if hasAdminPerms then
        RegisterKeyMapping("noclip", "No Clip", "keyboard", "n")
        RegisterKeyMapping("+deletelaser", "Delete Laser", "keyboard", "l")
        RegisterKeyMapping(Config.CommandName, "Open Admin Menu", "keyboard", "u")
        RegisterKeyMapping("teleporttomarker", "Teleport to Marker", "keyboard", "m")
        RegisterKeyMapping("fixvehiclekeybind", "Fix Vehicle", "keyboard", "i")
        RegisterKeyMapping("admincarkeybind", "Admin Car", "keyboard", "NUMPAD0")
        RegisterKeyMapping("godmodekeybind", "God Mode", "keyboard", "NUMPAD1")
        RegisterKeyMapping("invisiblekeybind", "Invisible", "keyboard", "NUMPAD2")
        RegisterKeyMapping("toggleblipskeybind", "Toggle Blips", "keyboard", "NUMPAD3")
        RegisterKeyMapping("togglenameskeybind", "Toggle Names", "keyboard", "NUMPAD4")
    else
        devMode = false
    end
end)

