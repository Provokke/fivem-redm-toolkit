fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'frt_ui_sample'
description 'Sample NUI panel that talks to frt_bridge'
author 'Provokke'
version '0.1.0'

dependency 'frt_bridge'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

client_script 'client.lua'
server_script 'server.lua'
