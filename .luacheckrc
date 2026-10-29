std = 'lua54'
max_line_length = 140
globals = { 'Config', 'Bridge', 'BridgeAdapters', 'exports' }
read_globals = {
    'GetResourceState', 'GetPlayerName', 'TriggerClientEvent', 'TriggerServerEvent',
    'RegisterCommand', 'RegisterNUICallback', 'SetNuiFocus', 'SendNUIMessage',
    'RegisterNetEvent', 'AddEventHandler', 'source',
}
files['spec'] = { std = '+busted' }
exclude_files = { '**/fxmanifest.lua' }
