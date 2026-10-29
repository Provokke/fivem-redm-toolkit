RegisterNetEvent('frt_ui_sample:hello', function()
    local src = source
    local fw = exports.frt_bridge:detect()
    exports.frt_bridge:notify(src, ('Hello from the %s adapter'):format(fw), 'success')
end)
