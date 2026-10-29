local S = require('bridge.sandbox')

local function world()
    return { [1] = { money = { cash = 100, bank = 500 }, items = { bread = 2 } } }
end

describe('Bridge.addMoney', function()
    it('rejects negative amount', function()
        local players = world()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(players) })
        local ok, reason = Bridge.addMoney(1, 'cash', -50)
        assert.is_false(ok)
        assert.equals('invalid_amount', reason)
        assert.equals(100, players[1].money.cash)
    end)

    it('rejects zero, non-numbers, NaN and infinity', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(world()) })
        for _, bad in ipairs({ 0, '50', true, {}, 0 / 0, math.huge, -math.huge }) do
            local ok, reason = Bridge.addMoney(1, 'cash', bad)
            assert.is_false(ok)
            assert.equals('invalid_amount', reason)
        end
        local ok, reason = Bridge.addMoney(1, 'cash', nil)
        assert.is_false(ok)
        assert.equals('invalid_amount', reason)
    end)

    it('rejects a bad account name', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(world()) })
        assert.is_false((Bridge.addMoney(1, nil, 10)))
        assert.is_false((Bridge.addMoney(1, '', 10)))
    end)

    for _, fw in ipairs({ 'qbox', 'qbcore', 'esx' }) do
        it('credits cash through the ' .. fw .. ' adapter', function()
            local players = world()
            local make = ({ qbox = S.qboxExports, qbcore = S.qbcoreExports, esx = S.esxExports })[fw]
            local res = ({ qbox = 'qbx_core', qbcore = 'qb-core', esx = 'es_extended' })[fw]
            local Bridge = S.load({ started = { [res] = true }, exports = make(players) })
            local ok = Bridge.addMoney(1, 'cash', 25)
            assert.is_true(ok)
            assert.equals(125, players[1].money.cash)
        end)
    end

    it('reports an unknown account as rejected, not an error', function()
        local players = world()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(players) })
        local ok, reason = Bridge.addMoney(1, 'nope', 10)
        assert.is_false(ok)
        assert.equals('rejected', reason)
    end)

    it('credits in memory on standalone', function()
        local Bridge, env = S.load({ players = { [3] = 'Test' } })
        assert.is_true(Bridge.addMoney(3, 'cash', 10))
        assert.equals(10, env.BridgeAdapters.standalone.state.money[3].cash)
    end)
end)
