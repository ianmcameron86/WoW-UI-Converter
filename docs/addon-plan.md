# In-game addon plan

## Goal

An addon that moves **keybinds** and the **Edit Mode layout** between WoW versions from inside the game, in any direction. Ian's priority is making the UI and keybinds match. Placing spells on action bars is **not** a goal for now.

## Why an addon as well as the web tool

- **No files, no restarting:** it works while the game is running. The keybind file copy needs both games closed, and the addon doesn't.
- **Keybinds and layout in one string:** there's no separate layout paste step.
- **Discoverable:** WoW players already find tools on CurseForge and Wago.

## Status

Not started. A read-only probe addon is built and **installed in all four of Ian's clients** (`_retail_`, `_anniversary_`, `_classic_beta_`, `_classic_era_`), waiting for him to run `/wucprobe full` in each.

**Probe 0.1 ran in Forever and Anniversary on Sept 24, 2026.** Findings below. Two bugs were found and fixed in 0.2:

- **The report window was empty.** The EditBox is a ScrollFrame child and had no height set, so it rendered nothing. The report itself was always fine: it was intact in SavedVariables the whole time. 0.2 sizes the box to the text.
- **Retail said "Incompatible".** The TOC interface numbers were guesses and all wrong. The real ones, taken from the clients themselves rather than guessed, are now in the TOC: **120001** Retail (Midnight), **20506** Anniversary/BC, **16001** Forever. Classic Era is still a guess at 11507.

## What the probe found

| | Forever (`_classic_beta_`) | Anniversary / BC (`_anniversary_`) |
|---|---|---|
| Version | 1.60.1 build 70009 | 2.5.6 build 69795 |
| tocversion | 16001 | 20506 |
| `WOW_PROJECT_ID` | **1, i.e. MAINLINE** | 5 |
| `C_EditMode` | present | present |
| `EditModeManagerFrame` | present | present |
| `GetNumBindings()` | 289, 134 bound | 270, 122 bound |

- **Forever identifies as MAINLINE, not Classic.** It installs into `_classic_beta_` but `WOW_PROJECT_ID` is 1. So the folder name is not a reliable guide to which code base a client runs.
- **Both clients expose the same `C_EditMode`:** `ConvertLayoutInfoToString`, `ConvertStringToLayoutInfo`, `GetAccountSettings`, `GetLayouts`, `IsValidLayoutName`, `OnEditModeExit`, `OnLayoutAdded`, `OnLayoutDeleted`, `SaveLayouts`, `SetAccountSetting`, `SetActiveLayout`. Forever also has `GetEditModeDefaultLayout`.
- **`EditModeManagerFrame:ImportLayout` exists in both.** That's the call Edit Mode's own import uses, and it's the most promising route for an addon applying a layout.
- **Reading layouts works.** `GetLayouts()` returned Forever's two layouts and BC's one, `ConvertLayoutInfoToString` produced strings matching what the files hold, and `ConvertStringToLayoutInfo` round-tripped.
- **The protection question is still open.** Every function reported `secure`, but `issecurevariable` only means *untainted*; it does not prove an addon can call it without the call being refused. The probe deliberately never tried to save a layout. That test still has to be run on purpose, with a backup. Nothing else is written yet, on purpose, because two design questions can't be answered from outside the game (see "The open question" below).

Because the probe writes its report to SavedVariables on logout, and Claude has read access to the WoW folder, the results can be read straight from
`WTF\Account\<account>\SavedVariables\WoWUIConverterProbe.lua`. No copying and pasting.

## What changed now that layouts are known to be files

Layouts live in `WTF\Account\<account>\edit-mode-cache-account.txt` (see `docs/layout-string-format.md`), and the web tool now reads them. That **weakens the case for the addon's layout half**: moving a layout no longer needs an in-game export at all, just the file. What the addon would still add:

- It works **without closing the game**, which the file route can't, since WoW only writes that file on logout.
- **Keybinds in the same step**, which is the part the file copy keeps losing to the server sync.

So if the layout write path turns out to be protected in-game, that's now much less of a problem than it looked.

## Decisions made

- **Two transports, both supported.** The addon can hand over a paste string, and it can also write its export to SavedVariables so the **web tool** moves it between installs, the same way the web tool already moves `bindings-cache.wtf`. Paste keeps the addon useful on its own; the SavedVariables route avoids pasting a multi-kilobyte string into a WoW edit box. Ian's Retail layout alone is about 2.4 KB before keybinds are added.
- **Probe before building.** Confirm the API surface in each client first.

## The open question, and why it decides the design

Whether an **addon** can apply an Edit Mode layout. Reading one is very likely fine. Saving one may be protected, the way parts of Edit Mode are in Retail. **This is inference, not confirmed.** It splits the design in two:

- **If an addon can apply layouts:** `/wuc import` previews the changes and applies them directly. One step.
- **If it can't:** the addon becomes an exporter and converter. It reads the source layout, converts it, and hands over a string for the user to paste into Edit Mode's own import box. Keybinds still apply directly. Two steps, less magical, but it still removes the file copying and the web tool round trip.

Either way the addon is worth building, so this doesn't block starting. It only decides whether import is one step or two.

What's already **verified** and doesn't need re-checking: Forever has Edit Mode, and its layout strings export and import. `reference/layouts/forever-beta-default.txt` came out of the Forever beta itself, and the converted Retail layout imported back into it.

## Proposed design (to confirm against the probe results)

- **Commands:**
  - `/wuc export`: shows a copyable string holding keybinds, the current Edit Mode layout, and a version tag. Also stores it in SavedVariables.
  - `/wuc import`: paste a string, preview what will change, then apply.
  - `/wuc undo`: restore the pre-import backup.
- **Keybinds:**
  - read: `GetNumBindings()` / `GetBinding(i)` (command, key1, key2)
  - apply: `SetBinding(key, command)` then `SaveBindings(GetCurrentBindingSet())`
  - both are blocked in combat (`InCombatLockdown()`), so refuse during combat
  - commands the destination doesn't know are skipped and listed for the user
- **Layout:**
  - read: `C_EditMode.GetLayouts()` / `C_EditMode.ConvertLayoutInfoToString()`
  - apply: `C_EditMode.ConvertStringToLayoutInfo()`, if that turns out to be allowed
  - convert with the same merge approach as `src/layout.js`, ported to Lua, using the destination client's own active layout as the base
  - save as a new layout, never overwriting an existing one, so it's always reversible
- **Backup:**
  - before an import, store the current bindings and layout in SavedVariables
  - `/wuc undo` restores them
- **String format:** a version prefix plus compressed, encoded data. LibDeflate plus LibSerialize is the usual choice. Include a checksum.
- **TOC:** one addon folder listing every client's interface number, e.g. `## Interface: 110200, 50500, 11507`. The real numbers come from the probe.
- **Packaging:** GitHub releases, plus CurseForge and Wago. Players install the same addon in each client's `Interface\AddOns` folder.

## What the probe answers

Run `addon/WoWUIConverterProbe` in Retail and in the Forever beta, then compare. See `addon/README.md` for how. It reports:

- **Interface number** and build, per client, for the TOC (`GetBuildInfo()`).
- **Does Forever have the API?** Whether `C_EditMode` and `EditModeManagerFrame` exist, and every function name they expose.
- **Exact names:** which of the functions we plan to call are actually present in each client, rather than assumed.
- **Is it protected?** `issecurevariable` on each function, which is the first hint about whether applying a layout is allowed.
- **Does the read path work?** It converts the live layout to a string and back, and prints the first 120 characters, so we can confirm the format matches what `src/layout.js` already parses.
- **Keybinds:** how many exist, how many are bound, and the full command list, which tells us how commands differ between versions.

It deliberately does **not** try to save a layout. That test needs to be deliberate and backed up, not a side effect of a probe.

## Still to check after the probe

- **Server copy:** whether `SaveBindings` gets overwritten by the server sync, the way the file copy can be.
- **Whether a layout can actually be saved** from an addon, tested on purpose with a backup in place.
