if not Config.Clothing ~= "fivem-appearance" then return end
RegisterNetEvent("sp-adminmenu:client:revertClothing", function()
    TriggerEvent("fivem-appearance:client:reloadSkin")
end)
