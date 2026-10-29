-- Qbox (qbx_core + ox_inventory). Names checked against a local Qbox server tree:
-- exports.qbx_core:GetPlayer(source), player.Functions.AddMoney(type, amount, reason),
-- exports.qbx_core:Notify(source, text, type, ...), exports.ox_inventory:GetItemCount(source, item).
BridgeAdapters = BridgeAdapters or {}

local kinds = { info = 'inform', success = 'success', error = 'error', warning = 'warning' }

BridgeAdapters.qbox = {
    getPlayer = function(src)
        return exports.qbx_core:GetPlayer(src)
    end,

    addMoney = function(player, _, name, amount)
        return player.Functions.AddMoney(name, amount, Config.moneyReason) == true
    end,

    itemCount = function(_, src, name)
        return exports.ox_inventory:GetItemCount(src, name) or 0
    end,

    notify = function(src, msg, kind)
        exports.qbx_core:Notify(src, msg, kinds[kind] or 'inform')
        return true
    end,
}
