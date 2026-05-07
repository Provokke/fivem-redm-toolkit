local S = require('bridge.sandbox')

describe('Bridge.detect', function()
    it('detects qbox before qbcore when both exports exist', function()
        local players = { [1] = { money = { cash = 0, bank = 0 }, items = {} } }
        local exp = S.qboxExports(players)
        for k, v in pairs(S.qbcoreExports(players)) do exp[k] = v end
        local Bridge = S.load({ started = { qbx_core = true, ['qb-core'] = true }, exports = exp })
        assert.equals('qbox', Bridge.detect())
    end)

    it('detects qbcore, then esx', function()
        assert.equals('qbcore', S.load({ started = { ['qb-core'] = true, es_extended = true } }).detect())
        assert.equals('esx', S.load({ started = { es_extended = true } }).detect())
    end)

    it('falls back to standalone', function()
        assert.equals('standalone', S.load({}).detect())
    end)

    it('does not count a stopped resource as present', function()
        local Bridge, env = S.load({ started = { qbx_core = true } })
        env.GetResourceState = function() return 'stopped' end
        assert.equals('standalone', Bridge.detect())
    end)

    it('honours a forced framework only when it is started', function()
        local started = { qbx_core = true, es_extended = true }
        assert.equals('esx', S.load({ started = started, config = { framework = 'esx' } }).detect())
        assert.equals('standalone', S.load({ started = started, config = { framework = 'standalone' } }).detect())
    end)
end)
