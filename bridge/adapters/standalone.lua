-- Standalone: no framework. Players are whoever the server reports; money and items
-- live in memory only and reset on resource restart. For development and tests.
BridgeAdapters = BridgeAdapters or {}

local state = { money = {}, items = {} }

BridgeAdapters.standalone = {
    state = state,

    getPlayer = function(src)
        local name = GetPlayerName(tostring(src))
        if not name then return nil end
        return { source = src, name = name }
    end,

    addMoney = function(_, src, account, amount)
        state.money[src] = state.money[src] or {}
        state.money[src][account] = (state.money[src][account] or 0) + amount
        return true
    end,

    itemCount = function(_, src, name)
        return (state.items[src] and state.items[src][name]) or 0
    end,

    notify = function(src, msg, kind)
        TriggerClientEvent('chat:addMessage', src, { args = { kind, msg } })
        return true
    end,
}
