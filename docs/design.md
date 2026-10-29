# Design note: the bridge

## Problem

Scripts written for one framework (`xPlayer.addAccountMoney`, `Player.Functions.AddMoney`, `exports.qbx_core:GetPlayer`) do not run on another. Studios and freelancers end up with three copies of every script, or a pile of `if Config.Framework == ...` branches inside the business logic.

## Decision

One module (`bridge/bridge.lua`) owns validation, framework choice and error handling. One small adapter per framework (`bridge/adapters/*.lua`) owns the framework-specific calls and nothing else. Adapters have four functions: `getPlayer`, `addMoney`, `itemCount`, `notify`.

## Rules the module enforces

1. **Nothing throws.** Every adapter call is behind `pcall`. A failure is `false, reason` (or `nil` / `false` for lookups). Reasons: `invalid_source`, `invalid_amount`, `invalid_account`, `invalid_message`, `framework_unavailable`, `adapter_missing`, `adapter_error`, `player_not_found`, `rejected`.
2. **Validate before touching the framework.** Money must be a finite number greater than zero. Sources must be positive integers. A caller bug (a negative amount, a string, NaN) never reaches `AddMoney`.
3. **Detection order is Qbox, QBCore, ESX, standalone.** Qbox can provide a qb-core compatibility layer, so on a Qbox server `qb-core` may also look started. Checking `qbx_core` first picks the right adapter.
4. **A forced framework never falls back.** `Config.framework = 'esx'` on a server without `es_extended` returns `framework_unavailable`. Silently crediting a different framework, or an in-memory ledger, would be worse than failing.
5. **`cash` is the API name for the wallet.** ESX calls it `money`; the ESX adapter maps it.
6. **Raw framework objects stay private to the bridge resource.** `server_exports.lua` returns only `{ source, framework }` to other resources.

## Testing approach

`bridge/sandbox.lua` loads the real files into a table used as their environment, with fake `GetResourceState`, `GetPlayerName`, `TriggerClientEvent` and fake framework `exports` that mimic the call shapes the adapters use (method call for `exports.x:Fn()`, dot call for `Player.Functions.AddMoney`). The specs and `make demo` both use it. Because the fakes are written by the same author as the adapters, passing specs show the bridge logic is consistent, not that the real frameworks behave as the fakes do. That needs a live server.

## Not covered

- RedM frameworks (VORP, RSG). The manifests target `gta5`. The adapter shape would carry over, but no RedM adapter exists here.
- Item metadata, slot handling, job and gang data, accounts beyond the basics.
- Client-side use. The bridge is server-side only.
