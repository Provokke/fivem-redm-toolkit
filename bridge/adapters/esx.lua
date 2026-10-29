-- ESX (es_extended). Names checked against ox_doorlock's ESX bridge and other resources
-- in a local server tree: exports.es_extended:getSharedObject(), ESX.GetPlayerFromId,
-- xPlayer.addAccountMoney / getAccount / getInventoryItem / showNotification.
BridgeAdapters = BridgeAdapters or {}

local ESX
local function core()
    if not ESX then ESX = exports['es_extended']:getSharedObject() end
    return ESX
end

-- ESX calls the wallet 'money'; the bridge API says 'cash'.
local function account(name)
    if name == 'cash' then return 'money' end
    return name
end

local kinds = { info = 'info', success = 'success', error = 'error', warning = 'info' }

BridgeAdapters.esx = {
    getPlayer = function(src)
        return core().GetPlayerFromId(src)
    end,

    addMoney = function(xPlayer, _, name, amount)
        local acc = account(name)
        if not xPlayer.getAccount(acc) then return false end
        xPlayer.addAccountMoney(acc, amount, Config.moneyReason)
        return true
    end,

    itemCount = function(xPlayer, _, name)
        local item = xPlayer.getInventoryItem(name)
        return item and item.count or 0
    end,

    notify = function(src, msg, kind)
        local xPlayer = core().GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.showNotification(msg, kinds[kind] or 'info')
        return true
    end,
}
