-- QBCore (qb-core). Names checked against resources in a local server tree:
-- exports['qb-core']:GetCoreObject(), QBCore.Functions.GetPlayer,
-- Player.Functions.AddMoney / GetItemByName, 'QBCore:Notify' client event.
BridgeAdapters = BridgeAdapters or {}

local QBCore
local function core()
    if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
    return QBCore
end

local kinds = { info = 'primary', success = 'success', error = 'error', warning = 'primary' }

BridgeAdapters.qbcore = {
    getPlayer = function(src)
        return core().Functions.GetPlayer(src)
    end,

    addMoney = function(player, _, name, amount)
        return player.Functions.AddMoney(name, amount, Config.moneyReason) == true
    end,

    itemCount = function(player, _, name)
        local item = player.Functions.GetItemByName(name)
        return item and item.amount or 0
    end,

    notify = function(src, msg, kind)
        TriggerClientEvent('QBCore:Notify', src, msg, kinds[kind] or 'primary', 5000)
        return true
    end,
}
