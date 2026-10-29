local S = require('bridge.sandbox')

local function world()
    return { [1] = { money = { cash = 0, bank = 0 }, items = { bread = 2 } } }
end

describe('Bridge.hasItem', function()
    it('hasItem false for missing player', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(world()) })
        assert.is_false(Bridge.hasItem(99, 'bread', 1))
        assert.is_false(Bridge.hasItem(nil, 'bread', 1))
    end)

    for _, fw in ipairs({ 'qbox', 'qbcore', 'esx' }) do
        it('counts items through the ' .. fw .. ' adapter', function()
            local make = ({ qbox = S.qboxExports, qbcore = S.qbcoreExports, esx = S.esxExports })[fw]
            local res = ({ qbox = 'qbx_core', qbcore = 'qb-core', esx = 'es_extended' })[fw]
            local Bridge = S.load({ started = { [res] = true }, exports = make(world()) })
            assert.is_true(Bridge.hasItem(1, 'bread'))
            assert.is_true(Bridge.hasItem(1, 'bread', 2))
            assert.is_false(Bridge.hasItem(1, 'bread', 3))
            assert.is_false(Bridge.hasItem(1, 'water', 1))
        end)
    end

    it('is false for a bad item name or count', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports(world()) })
        assert.is_false(Bridge.hasItem(1, nil, 1))
        assert.is_false(Bridge.hasItem(1, 'bread', -1))
        assert.is_false(Bridge.hasItem(1, 'bread', 0))
        assert.is_false(Bridge.hasItem(1, 'bread', 'two'))
    end)
end)

describe('Bridge.notify', function()
    it('sends through each framework', function()
        local players = world()
        local qlog, elog = {}, {}
        local q = S.load({ started = { qbx_core = true }, exports = S.qboxExports(players, qlog) })
        assert.is_true(q.notify(1, 'hi', 'success'))
        assert.same({ 1, 'hi', 'success' }, qlog[1])

        local e = S.load({ started = { es_extended = true }, exports = S.esxExports(players, elog) })
        assert.is_true(e.notify(1, 'hi', 'error'))
        assert.same({ 1, 'hi', 'error' }, elog[1])

        local c, cenv = S.load({ started = { ['qb-core'] = true }, exports = S.qbcoreExports(players) })
        assert.is_true(c.notify(1, 'hi', 'info'))
        assert.equals('QBCore:Notify', cenv.events[1][1])
    end)

    it('returns a reason for bad input', function()
        local Bridge = S.load({})
        assert.same({ false, 'invalid_source' }, { Bridge.notify(nil, 'x') })
        assert.same({ false, 'invalid_message' }, { Bridge.notify(1, nil) })
        assert.same({ false, 'invalid_message' }, { Bridge.notify(1, '') })
    end)
end)
