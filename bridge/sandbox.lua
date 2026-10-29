-- Loads the bridge outside FXServer with fake natives and fake framework exports.
-- Used by the busted specs and `make demo`. Not part of the FiveM resource manifest.
local S = {}

local root = (debug.getinfo(1, 'S').source:sub(2):match('^(.*)[/\\]') or '.') .. '/'
local FILES = {
    'config.lua', 'adapters/standalone.lua', 'adapters/esx.lua',
    'adapters/qbcore.lua', 'adapters/qbox.lua', 'bridge.lua',
}

-- opts: started = { [resource]=true }, exports = {...}, players = { [src]=name }, config = {...}
function S.load(opts)
    opts = opts or {}
    local env = setmetatable({}, { __index = _G })
    env.events = {}
    env.GetResourceState = function(name)
        return (opts.started or {})[name] and 'started' or 'missing'
    end
    env.GetPlayerName = function(src)
        return (opts.players or {})[tonumber(src)]
    end
    env.TriggerClientEvent = function(...) env.events[#env.events + 1] = { ... } end
    env.exports = opts.exports or {}
    for _, f in ipairs(FILES) do
        local chunk = assert(loadfile(root .. f, 't', env))
        chunk()
    end
    for k, v in pairs(opts.config or {}) do env.Config[k] = v end
    return env.Bridge, env
end

local function addMoney(p)
    return function(account, amount)
        if p.money[account] == nil then return false end
        p.money[account] = p.money[account] + amount
        return true
    end
end

-- players[src] = { money = {cash=0, bank=0}, items = {bread=2} }
function S.qboxExports(players, log)
    log = log or {}
    return {
        qbx_core = {
            GetPlayer = function(_, src)
                local p = players[src]
                if not p then return nil end
                return { Functions = { AddMoney = addMoney(p) } }
            end,
            Notify = function(_, src, msg, kind) log[#log + 1] = { src, msg, kind } end,
        },
        ox_inventory = {
            GetItemCount = function(_, src, name)
                return (players[src] and players[src].items[name]) or 0
            end,
        },
    }
end

function S.qbcoreExports(players)
    return {
        ['qb-core'] = {
            GetCoreObject = function()
                return { Functions = { GetPlayer = function(src)
                    local p = players[src]
                    if not p then return nil end
                    return { Functions = {
                        AddMoney = addMoney(p),
                        GetItemByName = function(name)
                            local n = p.items[name]
                            return n and { amount = n } or nil
                        end,
                    } }
                end } }
            end,
        },
    }
end

function S.esxExports(players, log)
    log = log or {}
    return {
        es_extended = {
            getSharedObject = function()
                return { GetPlayerFromId = function(src)
                    local p = players[src]
                    if not p then return nil end
                    local wallet = { money = 'cash', bank = 'bank' }
                    return {
                        getAccount = function(name) return wallet[name] and { name = name } or nil end,
                        addAccountMoney = function(name, amount) p.money[wallet[name]] = p.money[wallet[name]] + amount end,
                        getInventoryItem = function(name) return { count = p.items[name] or 0 } end,
                        showNotification = function(msg, kind) log[#log + 1] = { src, msg, kind } end,
                    }
                end }
            end,
        },
    }
end

return S
