Config = Config or {}

-- 'auto' picks the first started framework in Config.priority.
-- Or force one of 'esx' | 'qbcore' | 'qbox' | 'standalone'. A forced framework that
-- is not started makes the bridge return errors instead of silently using another one.
Config.framework = 'auto'

-- Qbox first: it can also provide a qb-core compatibility layer, so qb-core may look
-- "started" on a Qbox server.
Config.priority = { 'qbox', 'qbcore', 'esx' }

Config.resources = {
    qbox = 'qbx_core',
    qbcore = 'qb-core',
    esx = 'es_extended',
}

-- Reason string passed to the framework's money functions (shows in logs).
Config.moneyReason = 'frt_bridge'
