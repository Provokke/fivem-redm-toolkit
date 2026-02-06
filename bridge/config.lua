Config = Config or {}

-- 'auto' picks the first started framework in Config.priority. Or force one of
-- 'esx', 'qbcore', 'qbox' or 'standalone'. If the forced one isn't started the
-- bridge returns errors rather than quietly using another.
Config.framework = 'auto'

-- Qbox goes first because it can provide a qb-core compat layer, so qb-core
-- can look "started" on a Qbox server.
Config.priority = { 'qbox', 'qbcore', 'esx' }

Config.resources = {
    qbox = 'qbx_core',
    qbcore = 'qb-core',
    esx = 'es_extended',
}

-- Reason passed to the framework's money functions (shows in logs).
Config.moneyReason = 'frt_bridge'
