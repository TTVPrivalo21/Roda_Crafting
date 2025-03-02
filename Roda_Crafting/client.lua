ESX = exports["es_extended"]:getSharedObject()

Citizen.CreateThread(function()
    for i, point in ipairs(Config.CraftingPoints) do
        exports.ox_target:addBoxZone({
            coords = point.coords,
            size = vec3(1.0, 1.0, 1.0),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = "gangCraft_" .. i,
                    icon = point.icon or "fas fa-wrench",
                    label = point.label or "Abrir Mesa de Crafteo",
                    onSelect = function()
                        OpenCraftMenu(i)
                    end,
                    distance = point.radius or 2.0
                }
            }
        })
    end
end)

local currentPage = 1
local itemsPerPage = 10  -- Número de ítems por página

function OpenCraftMenu(pointIndex)
    ESX.TriggerServerCallback("gangCrafting:openBench", function(success, data)
        if not success then
            ESX.ShowNotification(data)
            return
        end

        local itemList = data
        local totalPages = math.ceil(#itemList / itemsPerPage)

        local function showPage(page)
            local startIndex = (page - 1) * itemsPerPage + 1
            local endIndex = math.min(page * itemsPerPage, #itemList)

            local elements = {}
            for i = startIndex, endIndex do
                local itemData = itemList[i]
                table.insert(elements, {
                    label = ("%s | Coste: $%d"):format(itemData.name, itemData.cost),
                    itemName = itemData.name,
                    duration = itemData.duration or 5000
                })
            end

            -- Botones de navegación
            if totalPages > 1 then
                if page > 1 then
                    table.insert(elements, {label = "← Página anterior", value = "prev"})
                end
                if page < totalPages then
                    table.insert(elements, {label = "→ Página siguiente", value = "next"})
                end
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gang_crafting_menu', {
                title = "Crafteo de Items - Página " .. page .. "/" .. totalPages,
                align = 'right',
                elements = elements
            }, function(data2, menu2)
                if data2.current.value == "prev" then
                    currentPage = math.max(1, currentPage - 1)
                    menu2.close()
                    showPage(currentPage)
                elseif data2.current.value == "next" then
                    currentPage = math.min(totalPages, currentPage + 1)
                    menu2.close()
                    showPage(currentPage)
                else
                    local chosenItem = data2.current.itemName
                    local craftDuration = data2.current.duration
                    menu2.close()
                    StartCraftingAnimation(pointIndex, chosenItem, craftDuration)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end

        showPage(currentPage)
    end, pointIndex)
end


-- Función para reproducir animación antes de craftear
function StartCraftingAnimation(pointIndex, chosenItem, craftDuration)
    local playerPed = PlayerPedId()
    local animDict = "amb@world_human_bum_wash@male@high@base"
    local animName = "base"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end

    -- Iniciar animación de crafteo
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, craftDuration, 49, 0, false, false, false)

    -- (Opcional) Mostrar barra de progreso
    if exports['progressBars'] then
        exports['progressBars']:startUI(craftDuration, "Crafteando...")  
    end

    Citizen.Wait(craftDuration)
    ClearPedTasks(playerPed)

    -- Una vez terminada la animación, enviar el crafteo al servidor
    TriggerServerEvent("gangCrafting:craftItem", pointIndex, chosenItem)
end

