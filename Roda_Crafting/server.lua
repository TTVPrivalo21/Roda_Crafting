ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback("gangCrafting:openBench", function(source, cb, pointIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(false, "No se encontró al jugador.")
        return
    end

    local cfg = Config.CraftingPoints[pointIndex]
    if not cfg then
        cb(false, "Punto de crafteo inválido.")
        return
    end

    local result = MySQL.single.await('SELECT gang FROM users WHERE identifier = ?', {xPlayer.identifier})
    local playerGang = result and result.gang or xPlayer.job.name or "none"

    if playerGang ~= cfg.gang then
        cb(false, "No tienes el trabajo requerido.")
        return
    end

    local itemList = {}
    for _, category in ipairs(cfg.categories) do
        local catItems = Items[category]
        if catItems then
            for _, itemData in ipairs(catItems) do
                table.insert(itemList, itemData)
            end
        end
    end

    cb(true, itemList)
end)

RegisterNetEvent("gangCrafting:craftItem", function(pointIndex, itemName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local cfg = Config.CraftingPoints[pointIndex]
    if not cfg then return end

    local result = MySQL.single.await('SELECT gang FROM users WHERE identifier = ?', {xPlayer.identifier})
    local playerGang = result and result.gang or xPlayer.job.name or "none"

    if playerGang ~= cfg.gang then
        TriggerClientEvent("esx:showNotification", src, "No tienes acceso a este punto de crafteo.")
        return
    end

    local foundItem = nil
    for _, category in ipairs(cfg.categories) do
        local catItems = Items[category]
        if catItems then
            for _, iData in ipairs(catItems) do
                if iData.name == itemName then
                    foundItem = iData
                    break
                end
            end
        end
        if foundItem then break end
    end

    if not foundItem then
        TriggerClientEvent("esx:showNotification", src, "Este ítem no está disponible en esta mesa.")
        return
    end

    if xPlayer.getMoney() < foundItem.cost then
        TriggerClientEvent("esx:showNotification", src, "No tienes suficiente dinero.")
        return
    end

    xPlayer.removeMoney(foundItem.cost)
    xPlayer.addInventoryItem(foundItem.name, foundItem.count or 1)

    TriggerClientEvent("esx:showNotification", src, ("Has creado x%d %s"):format(foundItem.count or 1, foundItem.name))
end)