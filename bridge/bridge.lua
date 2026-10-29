-- One API over ESX / QBCore / Qbox / standalone. Nothing here throws: bad input,
-- a missing framework or an adapter that errors all come back as `false, reason`
-- (or nil / false for the lookups).
Bridge = Bridge or {}
BridgeAdapters = BridgeAdapters or {}

local function started(resource)
    if type(GetResourceState) ~= 'function' then return false end
    local ok, state = pcall(GetResourceState, resource)
    return ok and state == 'started'
end

local function validSource(src)
    return type(src) == 'number' and src == src and src > 0 and src % 1 == 0
end

local function validAmount(n)
    return type(n) == 'number' and n == n and n > 0 and n < math.huge
end

local function validName(s)
    return type(s) == 'string' and s ~= ''
end

-- Returns 'qbox' | 'qbcore' | 'esx' | 'standalone'.
function Bridge.detect()
    local cfg = Config or {}
    local resources = cfg.resources or {}
    local forced = cfg.framework
    if forced == 'standalone' then return 'standalone' end
    if forced and forced ~= 'auto' and started(resources[forced] or '') then return forced end
    for _, name in ipairs(cfg.priority or { 'qbox', 'qbcore', 'esx' }) do
        if started(resources[name] or '') then return name end
    end
    return 'standalone'
end

-- adapter, framework  |  nil, reason
local function resolve()
    local forced = (Config or {}).framework or 'auto'
    local fw = Bridge.detect()
    if forced ~= 'auto' and forced ~= fw then return nil, 'framework_unavailable' end
    local adapter = BridgeAdapters[fw]
    if not adapter then return nil, 'adapter_missing' end
    return adapter, fw
end

-- raw, adapter, framework  |  nil, reason
local function lookup(src)
    if not validSource(src) then return nil, 'invalid_source' end
    local adapter, fw = resolve()
    if not adapter then return nil, fw end
    local ok, raw = pcall(adapter.getPlayer, src)
    if not ok then return nil, 'adapter_error' end
    if raw == nil or raw == false then return nil, 'player_not_found' end
    return raw, adapter, fw
end

-- table { source, framework, raw } | nil
function Bridge.getPlayer(src)
    local raw, _, fw = lookup(src)
    if raw == nil then return nil end
    return { source = src, framework = fw, raw = raw }
end

-- true | false, reason. `account` is 'cash' | 'bank' | ... (ESX 'money' is mapped from 'cash').
function Bridge.addMoney(src, account, amount)
    if not validAmount(amount) then return false, 'invalid_amount' end
    if not validName(account) then return false, 'invalid_account' end
    local raw, adapter = lookup(src)
    if raw == nil then return false, adapter end
    local ok, result = pcall(adapter.addMoney, raw, src, account, amount)
    if not ok then return false, 'adapter_error' end
    if result ~= true then return false, 'rejected' end
    return true
end

-- true when the player holds at least `count` (default 1).
function Bridge.hasItem(src, name, count)
    if count == nil then count = 1 end
    if not validName(name) or not validAmount(count) then return false end
    local raw, adapter = lookup(src)
    if raw == nil then return false end
    local ok, have = pcall(adapter.itemCount, raw, src, name)
    if not ok or type(have) ~= 'number' then return false end
    return have >= count
end

-- kind: 'info' | 'success' | 'error' | 'warning'. true | false, reason.
function Bridge.notify(src, msg, kind)
    if not validSource(src) then return false, 'invalid_source' end
    if type(msg) ~= 'string' or msg == '' then return false, 'invalid_message' end
    local adapter, fw = resolve()
    if not adapter then return false, fw end
    local ok, result = pcall(adapter.notify, src, msg, kind or 'info')
    if not ok then return false, 'adapter_error' end
    if result ~= true then return false, 'rejected' end
    return true
end
