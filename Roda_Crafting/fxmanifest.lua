fx_version 'cerulean'
game 'gta5'

description 'Script de crafteo para trabajos'
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',     
    'items.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'items.lua',
    'client.lua'
}

dependencies {
    'es_extended',
    'ox_target',   
    'ox_inventory'  
}
