# 📌 Sistema de Crafteo para Gangs en FiveM ESX

## 📖 Descripción
Este sistema permite a los jugadores craftear objetos en mesas de crafteo exclusivas para cada gang. 
Se basa en Roda_GangsCreator y requiere configurar ciertos parámetros en la base de datos y en `es_extended`.

## 📂 Instalación y Configuración

### 1️⃣ **Agregar el recurso a tu servidor**
1. Descarga o clona este repositorio en tu carpeta `resources`.
2. Agrega `ensure Roda_Crafting` en tu `server.cfg`.

### 2️⃣ **Configurar puntos de crafteo** (`config.lua`)
Cada mesa de crafteo debe tener un `gang` o `trabajo`  asociado y categorías de ítems:

```lua
Config.CraftingPoints = {
    -- Roda_GangsCreator = https://github.com/RodericAguilar/Roda_GangsCreator
    {
        coords = vector3(552.85, -2773.82, 6.09),
        gang = "gang", -- OCUPA EL GANG DE BASE SCRIPT RODA_GANGSCREATOS
        categories = { "tipo de mesa" },
        radius = 2.0,
        label = "Mesa de Comida",
        icon = "fas fa-cogs"
    },
    -- trabajo = trabajo jobcreator
    {
        coords = vector3(552.85, -2773.82, 6.09),
        gang = "police", -- trabajo
        categories = { "comida" },
        radius = 2.0,
        label = "Mesa de Comida",
        icon = "fas fa-cogs"
    },
}
```

### 3️⃣ **Configurar ítems de crafteo** (`items.lua`)
Define los ítems que se pueden craftear en cada categoría:

```lua
Items = {
    ['drogas'] = {
        { name = "cock", cost = 7000, duration = 15000, count = 1 },
        { name = "packaged_weed", cost = 7000, duration = 15000, count = 1 }
    },
    ['armas'] = {
        { name = "weapon_pistol", cost = 9000, duration = 15000, count = 1, },
    },
}
```

### 4️⃣ **Modificar `es_extended` para incluir `gang` en los datos del jugador**
En `es_extended/server/main.lua`, reemplaza la función `esx:getPlayerData` con esta versión modificada:

```lua
ESX.RegisterServerCallback("esx:getPlayerData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    local playerData = {
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        job_grade = xPlayer.getJob().grade,
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
        position = xPlayer.getCoords(true),
        metadata = xPlayer.getMeta()
    }

    MySQL.Async.fetchAll("SELECT gang, gang_grade FROM users WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            playerData.gang = result[1].gang or "none"
            playerData.gang_grade = result[1].gang_grade or 0
        else
            playerData.gang = "none"
            playerData.gang_grade = 0
        end
        cb(playerData)
    end)
end)
```

## 🎮 Uso en el Servidor
1. Un jugador debe estar en su mesa de crafteo correspondiente.
2. Al interactuar con la mesa, verá los ítems disponibles para su gang.
3. Debe pagar el costo del ítem para craftearlo y recibirlo en su inventario.

------------------------------------------------------------------------------------------------------------------------------------

# 📌 FiveM Gang Crafting System ESX

## 📖 Description
This system allows players to craft items at gang-specific crafting benches. 
It is based on Roda_GangsCreator and requires configuring certain parameters in the database and `es_extended`.

## 📂 Installation and Configuration

### 1️⃣ **Add the Resource to Your Server**
1. Download or clone this repository into your `resources` folder.
2. Add `ensure Roda_Crafting` in your `server.cfg`.

### 2️⃣ **Configure Crafting Points** (`config.lua`)
Each crafting bench must be assigned to a `gang` and item categories:

```lua
Config.CraftingPoints = {
    -- Roda_GangsCreator = https://github.com/RodericAguilar/Roda_GangsCreator
    {
        coords = vector3(552.85, -2773.82, 6.09),
        gang = "gang", -- OCCUPY THE BASE GANG SCRIPT RODA_GANGSCREATOS
        categories = { "tipo de mesa" },
        radius = 2.0,
        label = "Mesa de Comida",
        icon = "fas fa-cogs"
    },
    -- job = job jobcreator
    {
        coords = vector3(552.85, -2773.82, 6.09),
        gang = "police", -- job
        categories = { "comida" }, -- Category items
        radius = 2.0,
        label = "Mesa de Comida",
        icon = "fas fa-cogs"
    },
}
```

### 3️⃣ **Configure Crafting Items** (`items.lua`)
Define the items that can be crafted in each category:

```lua
Items = {
    ['drugs'] = {
        { name = "cock", cost = 7000, duration = 15000, count = 1 },
        { name = "packaged_weed", cost = 7000, duration = 15000, count = 1 }
    },
    ['guns'] = {
        { name = "weapon_pistol", cost = 9000, duration = 15000, count = 1, },
    },
}
```

### 4️⃣ **Modify `es_extended` to Include `gang` in Player Data**
In `es_extended/server/main.lua`, replace the `esx:getPlayerData` function with this modified version:

```lua
ESX.RegisterServerCallback("esx:getPlayerData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    local playerData = {
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        job_grade = xPlayer.getJob().grade,
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
        position = xPlayer.getCoords(true),
        metadata = xPlayer.getMeta()
    }

    MySQL.Async.fetchAll("SELECT gang, gang_grade FROM users WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            playerData.gang = result[1].gang or "none"
            playerData.gang_grade = result[1].gang_grade or 0
        else
            playerData.gang = "none"
            playerData.gang_grade = 0
        end
        cb(playerData)
    end)
end)
```

## 🎮 How to Use In-Game
1. A player must be at their assigned crafting bench.
2. When interacting with the bench, they will see the available items for their gang.
3. They must pay the item cost to craft it and receive it in their inventory.

---

Este README proporciona una guía clara sobre cómo instalar, configurar y usar el sistema de crafteo para gangs en FiveM. 🚀

