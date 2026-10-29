# fivem-redm-toolkit

A small FiveM Lua resource pack: **one server-side API (`getPlayer`, `addMoney`, `hasItem`, `notify`) over ESX, QBCore, Qbox and standalone**, plus a sample NUI resource that uses it.

Despite the repo name, only FiveM (GTA V) frameworks are implemented. There is no RedM adapter yet (see [docs/design.md](docs/design.md)).

## What

Scripts written for one framework do not run on another. This bridge puts the framework differences in four small adapters and keeps validation and error handling in one place:

- Detects the framework from started resources: Qbox, then QBCore, then ESX, else standalone.
- `Bridge.addMoney` rejects negative, zero, non-number, NaN and infinite amounts with `false, reason` before any framework call.
- A missing framework, a nil player or an adapter that errors returns a clean error. Nothing throws.
- A forced framework (`Config.framework = 'esx'`) that is not running returns `framework_unavailable`; it never falls back to another one.

| Call | Returns |
|---|---|
| `Bridge.detect()` | `'qbox' \| 'qbcore' \| 'esx' \| 'standalone'` |
| `Bridge.getPlayer(src)` | `{ source, framework, raw }` or `nil` |
| `Bridge.addMoney(src, account, amount)` | `true` or `false, reason` |
| `Bridge.hasItem(src, name, count?)` | `boolean` |
| `Bridge.notify(src, msg, kind?)` | `true` or `false, reason` |

Other resources call it through exports: `exports.frt_bridge:addMoney(src, 'cash', 100)`.

## 2-minute demo

Needs Lua 5.4 only. No FiveM server, no accounts, no network.

```bash
make demo          # or: lua demo/demo.lua
```

It loads the real bridge against fake natives and fake framework exports, and prints, for each of Qbox, QBCore and ESX: detection, a successful credit, item checks, and the failure cases (negative amount, string amount, nil player, unknown player), then a forced-but-missing framework and standalone. Sample lines:

```
[qbox server]
  detect()                           -> qbox
  addMoney(1, cash, 25)              -> true
  addMoney(1, cash, -5)              -> false, invalid_amount
  addMoney(nil, cash, 5)             -> false, invalid_source
[no framework, Config.framework = "qbox"]
  addMoney(1, cash, 5)               -> false, framework_unavailable
```

Tests: `luarocks install busted && make test`. Lint: `luarocks install luacheck && make lint`.

## Architecture

```
bridge/                 resource: frt_bridge (server only)
  config.lua            framework override, detection priority, resource names
  bridge.lua            validation, detection, pcall-wrapped dispatch
  adapters/             esx.lua  qbcore.lua  qbox.lua  standalone.lua
  server_exports.lua    exports for other resources (FXServer only)
  sandbox.lua           offline loader + fake natives/exports (tests, demo)
ui_sample/              resource: frt_ui_sample (NUI panel -> server -> bridge.notify)
spec/                   busted specs
demo/demo.lua           offline demo
docs/design.md          design note
```

Framework calls used, taken from resources in a local FiveM server tree (ESX and QBCore names) and its Qbox core (Qbox names):

| Framework | Player | Money | Items | Notify |
|---|---|---|---|---|
| Qbox | `exports.qbx_core:GetPlayer(src)` | `player.Functions.AddMoney(type, amount, reason)` | `exports.ox_inventory:GetItemCount(src, name)` | `exports.qbx_core:Notify(src, text, type)` |
| QBCore | `exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)` | `Player.Functions.AddMoney(...)` | `Player.Functions.GetItemByName(name).amount` | `TriggerClientEvent('QBCore:Notify', ...)` |
| ESX | `exports['es_extended']:getSharedObject().GetPlayerFromId(src)` | `xPlayer.addAccountMoney(account, amount, reason)` | `xPlayer.getInventoryItem(name).count` | `xPlayer.showNotification(msg, type)` |

Install on a server: copy `bridge/` and `ui_sample/` into `resources/`, rename the folders to `frt_bridge` and `frt_ui_sample` (the manifests and exports use those names), `ensure frt_bridge` after your framework.

## Verified vs NOT verified

**Verified (on a Windows dev machine, Lua 5.4.6):**
- `make demo` equivalent (`lua demo/demo.lua`) runs offline and prints the output above. `make` itself is not installed on this machine, so the Makefile target was not run; the command it wraps was.
- The 33 spec examples in `spec/` pass. **Caveat:** real `busted` could not be installed here (its `luasystem` dependency needs a C compiler that is not present), so they were run with a throwaway ~40-line shim implementing the subset of the busted API the specs use (`describe`, `it`, `assert.is_true/is_false/is_nil/is_not_nil/equals/same`, `assert.has_no.errors`). The shim is not in the repo. Deliberately breaking the amount check made 3 examples fail, so the specs do detect that regression. The specs were written alongside the code, not strictly red-first against a real runner.
- `luacheck bridge spec demo ui_sample`: 0 warnings.
- Export and method names in the adapters match call sites found in a local server tree (see the table above).

**NOT verified:**
- Real `busted` has not run, and neither has the GitHub Actions workflow (`.github/workflows/ci.yml`); it was written but never executed.
- **Nothing has run on a live FXServer.** No adapter has touched a real ESX, QBCore or Qbox install. The fakes in `bridge/sandbox.lua` are written by the same author as the adapters, so they prove internal consistency, not framework behaviour.
- `server_exports.lua`, `ui_sample/` (client, server, NUI page) and the `fxmanifest.lua` files are not loaded by any test. The NUI sample was never opened in the game.
- ESX `showNotification` and QBCore notification type names, and the `getAccount` check in the ESX adapter, follow the framework docs and usage in other resources, not a tested install.
- No RedM support.

## Licence

MIT. See [LICENSE](LICENSE).
