name [[Chaos Script]]
description [[A script to cause chaos events in game]]
author [[Goobie]]
version [[0.1]]


fx_version 'adamant'
game 'gta5'


client_script {
    '@NativeUI/NativeUI.lua',
    'chaos_cl.lua',
    
}
server_script {
    'chaos_sv.lua',
    '@vrp/lib/utils.lua',
}