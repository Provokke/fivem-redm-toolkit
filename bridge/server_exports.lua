-- FXServer only (not loaded by the offline tests). Exposes the bridge to other resources:
--   exports.frt_bridge:addMoney(src, 'cash', 100)
exports('detect', function() return Bridge.detect() end)
exports('getPlayer', function(src)
    local p = Bridge.getPlayer(src)
    if not p then return nil end
    return { source = p.source, framework = p.framework } -- raw framework object stays private
end)
exports('addMoney', function(src, account, amount) return Bridge.addMoney(src, account, amount) end)
exports('hasItem', function(src, name, count) return Bridge.hasItem(src, name, count) end)
exports('notify', function(src, msg, kind) return Bridge.notify(src, msg, kind) end)
