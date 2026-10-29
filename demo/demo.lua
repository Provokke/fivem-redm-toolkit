-- Offline demo: runs the real bridge against fake natives and fake framework exports.
-- Usage: lua demo/demo.lua   (from the repo root)
package.path = './?.lua;' .. package.path
local S = require('bridge.sandbox')

local function show(label, ...)
    local parts = {}
    for i = 1, select('#', ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    print(string.format('  %-34s -> %s', label, table.concat(parts, ', ')))
end

local function newWorld()
    return { [1] = { money = { cash = 100, bank = 500 }, items = { bread = 2 } } }
end

local setups = {
    { 'qbox', 'qbx_core', S.qboxExports },
    { 'qbcore', 'qb-core', S.qbcoreExports },
    { 'esx', 'es_extended', S.esxExports },
}

for _, s in ipairs(setups) do
    local players = newWorld()
    local Bridge = S.load({ started = { [s[2]] = true }, exports = s[3](players) })
    print(('[%s server]'):format(s[1]))
    show('detect()', Bridge.detect())
    show('addMoney(1, cash, 25)', Bridge.addMoney(1, 'cash', 25))
    show('cash after', players[1].money.cash)
    show('hasItem(1, bread, 2)', Bridge.hasItem(1, 'bread', 2))
    show('hasItem(1, bread, 3)', Bridge.hasItem(1, 'bread', 3))
    show('addMoney(1, cash, -5)', Bridge.addMoney(1, 'cash', -5))
    show('addMoney(1, cash, "lots")', Bridge.addMoney(1, 'cash', 'lots'))
    show('addMoney(nil, cash, 5)', Bridge.addMoney(nil, 'cash', 5))
    show('addMoney(99, cash, 5)', Bridge.addMoney(99, 'cash', 5))
    show('getPlayer(nil)', Bridge.getPlayer(nil))
end

print('[no framework, Config.framework = "qbox"]')
local Bridge = S.load({ config = { framework = 'qbox' } })
show('addMoney(1, cash, 5)', Bridge.addMoney(1, 'cash', 5))

print('[standalone]')
local B2 = S.load({ players = { [1] = 'Alice' } })
show('detect()', B2.detect())
show('addMoney(1, cash, 10)', B2.addMoney(1, 'cash', 10))
