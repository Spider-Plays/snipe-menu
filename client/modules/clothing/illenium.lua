if Config.Clothing ~= "illenium-appearance" then return end
RegisterNetEvent("sp-adminmenu:client:revertClothing", function()
    TriggerEvent("illenium-appearance:client:reloadSkin")
end)