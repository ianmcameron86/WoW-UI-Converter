# In-game addon plan (not started)

## Goal

An addon that moves **keybinds** and the **Edit Mode layout** between WoW versions from inside the game, in any direction. Ian's priority is making the UI and keybinds match. Placing spells on action bars is **not** a goal for now.

## Why an addon as well as the web tool

- **No files, no restarting:** it works while the game is running. The keybind file copy needs both games closed, and the addon doesn't.
- **Keybinds and layout in one string:** there's no separate layout paste step.
- **Discoverable:** WoW players already find tools on CurseForge and Wago.

## Proposed design (to confirm against each client)

- **Commands:**
  - `/wuc export`: shows a copyable string holding keybinds, the current Edit Mode layout, and a version tag.
  - `/wuc import`: paste a string, preview what will change, then apply.
- **Keybinds:**
  - read: `GetNumBindings()` / `GetBinding(i)` (command, key1, key2)
  - apply: `SetBinding(key, command)` then `SaveBindings(GetCurrentBindingSet())`
  - both are blocked in combat (`InCombatLockdown()`), so refuse during combat
  - commands the destination doesn't know are skipped and listed for the user
- **Layout:**
  - read: `C_EditMode.GetLayouts()` / `C_EditMode.ConvertLayoutInfoToString()`
  - apply: `C_EditMode.ConvertStringToLayoutInfo()`
  - convert with the same merge approach as `src/layout.js`, ported to Lua, using the destination client's own active layout as the base
  - save as a new layout, never overwriting an existing one, so it's always reversible
- **Backup:**
  - before an import, store the current bindings and layout in SavedVariables
  - `/wuc undo` restores them
- **String format:** a version prefix plus compressed, encoded data. LibDeflate plus LibSerialize is the usual choice. Include a checksum.
- **TOC:** one addon folder listing every client's interface number, e.g. `## Interface: 110200, 50500, 11507`. Confirm the current numbers per client, including Forever's.
- **Packaging:** GitHub releases, plus CurseForge and Wago. Players install the same addon in each client's `Interface\AddOns` folder.

## Unknowns to check first (in-game, with Ian)

- **Does Forever have the API?** Does the Forever beta client (Classic branch, `_classic_beta_`) have `C_EditMode` with the convert functions? Check with `/dump C_EditMode ~= nil`.
- **Exact names:** the exact function names and signatures in each client. Retail and Classic may differ.
- **Server copy:** whether `SaveBindings` gets overwritten by the server sync, as the file copy can be.
- **Interface numbers:** the TOC interface number for the Forever beta, from `/dump select(4, GetBuildInfo())`.

Start with a small test addon that dumps these values in each client before building the real thing.
