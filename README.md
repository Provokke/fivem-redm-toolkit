# fivem-redm-toolkit

A small FiveM Lua resource pack. It gives scripts one server-side API (`getPlayer`, `addMoney`, `hasItem`, `notify`) over ESX, QBCore, Qbox and standalone, plus a sample NUI resource that uses it.

Despite the repo name, only FiveM (GTA V) frameworks are implemented. There is no RedM adapter yet.

## How it works

The framework differences live in four small adapters, and validation and error handling live in one place. The framework is detected from started resources (Qbox, then QBCore, then ESX, else standalone). Set `Config.framework = 'esx'` to force one. A forced framework that isn't running returns `framework_unavailable` and never falls back to another.

Bad input (negative, zero, non-number, NaN or infinite amounts), a missing framework, a nil player or an adapter that errors all return `false, reason`. Nothing throws.

| Call | Returns |
|---|---|
| `Bridge.detect()` | `'qbox'`, `'qbcore'`, `'esx'` or `'standalone'` |
| `Bridge.getPlayer(src)` | `{ source, framework, raw }` or `nil` |
| `Bridge.addMoney(src, account, amount)` | `true` or `false, reason` |
| `Bridge.hasItem(src, name, count?)` | `boolean` |
| `Bridge.notify(src, msg, kind?)` | `true` or `false, reason` |

Other resources use exports, for example `exports.frt_bridge:addMoney(src, 'cash', 100)`.

## Install

Copy `bridge/` and `ui_sample/` into `resources/` and rename the folders to `frt_bridge` and `frt_ui_sample`, since the manifests and exports use those names. Then `ensure frt_bridge` after your framework.

## Offline demo, tests and lint

Needs Lua 5.4 only. No FiveM server or network.

```sh
make demo          # or: lua demo/demo.lua
luarocks install busted && make test
luarocks install luacheck && make lint
```

The demo loads the real bridge against fake natives and framework exports, then prints detection, credits, item checks and the failure cases for each framework.

## Status

Checked on Windows with Lua 5.4.6: the demo runs, `luacheck` is clean, and the 33 spec examples pass. Real `busted` wouldn't install there (no C compiler for `luasystem`), so the specs ran under a small shim covering the busted calls they use. The GitHub Actions workflow has never run.

Nothing has run on a live FXServer. The fakes in `bridge/sandbox.lua` are written by the same author as the adapters, so they only show the code agrees with itself. The framework call names came from resources in a local server tree and framework docs. `server_exports.lua`, `ui_sample/` and the manifests are not loaded by any test, and the NUI sample was never opened in game.

## Licence

MIT. See LICENSE.
