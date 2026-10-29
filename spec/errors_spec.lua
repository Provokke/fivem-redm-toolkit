local S = require('bridge.sandbox')

describe('clean errors, never a throw', function()
    it('missing framework: a forced framework that is not started', function()
        local Bridge = S.load({ started = {}, config = { framework = 'qbox' }, players = { [1] = 'A' } })
        assert.same({ false, 'framework_unavailable' }, { Bridge.addMoney(1, 'cash', 10) })
        assert.same({ false, 'framework_unavailable' }, { Bridge.notify(1, 'hi') })
        assert.is_nil(Bridge.getPlayer(1))
        assert.is_false(Bridge.hasItem(1, 'bread'))
    end)

    it('missing framework: resource started but its exports are absent', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = {} })
        assert.has_no.errors(function()
            assert.is_nil(Bridge.getPlayer(1))
            assert.same({ false, 'adapter_error' }, { Bridge.addMoney(1, 'cash', 10) })
            assert.is_false(Bridge.hasItem(1, 'bread'))
            assert.same({ false, 'adapter_error' }, { Bridge.notify(1, 'hi') })
        end)
    end)

    it('missing framework: no exports table at all', function()
        local Bridge, env = S.load({ started = { es_extended = true } })
        env.exports = nil
        assert.has_no.errors(function() Bridge.getPlayer(1) end)
        assert.is_nil(Bridge.getPlayer(1))
    end)

    it('a missing adapter is reported', function()
        local Bridge, env = S.load({ started = { es_extended = true } })
        env.BridgeAdapters.esx = nil
        assert.same({ false, 'adapter_missing' }, { Bridge.addMoney(1, 'cash', 5) })
    end)

    it('nil player: every call with a nil source is clean', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports({}) })
        assert.has_no.errors(function()
            Bridge.getPlayer(nil)
            Bridge.addMoney(nil, 'cash', 10)
            Bridge.hasItem(nil, 'bread', 1)
            Bridge.notify(nil, 'hi')
        end)
        assert.same({ false, 'invalid_source' }, { Bridge.addMoney(nil, 'cash', 10) })
    end)

    it('player the framework cannot find: addMoney says so', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports({}) })
        assert.same({ false, 'player_not_found' }, { Bridge.addMoney(5, 'cash', 10) })
    end)

    it('an adapter that throws is contained', function()
        local players = { [1] = { money = { cash = 0 }, items = {} } }
        local Bridge, env = S.load({ started = { qbx_core = true }, exports = S.qboxExports(players) })
        env.BridgeAdapters.qbox.addMoney = function() error('boom') end
        env.BridgeAdapters.qbox.itemCount = function() error('boom') end
        assert.same({ false, 'adapter_error' }, { Bridge.addMoney(1, 'cash', 10) })
        assert.is_false(Bridge.hasItem(1, 'bread'))
    end)

    it('negative, non-number and NaN money never throw even with no framework', function()
        local Bridge = S.load({})
        assert.has_no.errors(function()
            Bridge.addMoney(1, 'cash', -1)
            Bridge.addMoney(1, 'cash', 'x')
            Bridge.addMoney(1, 'cash', 0 / 0)
        end)
    end)
end)
