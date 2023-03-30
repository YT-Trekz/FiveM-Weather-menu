fx_version 'adamant'
game 'gta5'

author 'MadeByアンディ | L-Leaks Scripts'
description 'L-WeerMenu'
version '1.0.0'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua', 
    'locales/nl.lua', 
    'client/client.lua'
}

shared_scripts {
   'config.lua'
}

server_script {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/nl.lua',   
    'server/server.lua'
}