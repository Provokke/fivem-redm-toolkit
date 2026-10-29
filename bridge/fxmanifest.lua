fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'frt_bridge'
description 'One server-side API over ESX, QBCore, Qbox and standalone'
author 'Provokke'
version '0.1.0'

server_scripts {
    'config.lua',
    'adapters/standalone.lua',
    'adapters/esx.lua',
    'adapters/qbcore.lua',
    'adapters/qbox.lua',
    'bridge.lua',
    'server_exports.lua',
}
