fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Quantom Dev'
description 'Système de gestion des clés de véhicules avec menu concessionnaire'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/functions.lua',
    'client/keybinds.lua',
    'client/main.lua',
    'client/cardealer.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/cardealer.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/js/*.js'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'oxmysql'
}

