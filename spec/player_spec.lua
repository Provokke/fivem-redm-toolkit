local S = require('bridge.sandbox')

describe('Bridge.getPlayer', function()
    it('getPlayer nil returns nil not error', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports({}) })
        assert.has_no.errors(function() Bridge.getPlayer(nil) end)
        assert.is_nil(Bridge.getPlayer(nil))
    end)

    it('returns nil for a player the framework does not know', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports({}) })
        assert.is_nil(Bridge.getPlayer(42))
    end)

    it('returns nil for non-number, zero, negative and fractional sources', function()
        local Bridge = S.load({ started = { qbx_core = true }, exports = S.qboxExports({ [1] = { money = {}, items = {} } }) })
        for _, bad in ipairs({ '1', 0, -1, 1.5, true, {}, 0 / 0 }) do
            assert.is_nil(Bridge.getPlayer(bad))
        end
    end)

    it('wraps a known player with its framework', function()
        local players = { [7] = { money = { cash = 0 }, items = {} } }
        local Bridge = S.load({ started = { es_extended = true }, exports = S.esxExports(players) })
        local p = Bridge.getPlayer(7)
        assert.equals(7, p.source)
        assert.equals('esx', p.framework)
        assert.is_not_nil(p.raw)
    end)

    it('standalone knows players the server names', function()
        local Bridge = S.load({ players = { [2] = 'Alice' } })
        assert.equals('standalone', Bridge.getPlayer(2).framework)
        assert.is_nil(Bridge.getPlayer(3))
    end)
end)
