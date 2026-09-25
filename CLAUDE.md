# WoW UI Converter - project guide for Claude

Read this first. It carries over everything from the chat where this project started (Sept 24, 2026), so you can continue without the original conversation. Details are in `docs/`.

## What this is

A free, fan-made tool that lets World of Warcraft players copy their **keybinds** and **HUD (Edit Mode) layout** from the WoW version they're used to into any other version: Retail, WoW Forever (beta now, live later), Classic, betas and PTRs. It works in any direction, and every file it replaces is backed up with a one-click restore.

- Live site: https://ianmcameron86.github.io/WoW-UI-Converter/
- Repo: https://github.com/ianmcameron86/WoW-UI-Converter (public, GitHub Pages from `main` / root)
- Owner: Ian (GitHub `ianmcameron86`). This is a personal project on his personal PC. Keep it separate from his work (he's an MSP service desk engineer, so don't assume work context applies here).

## Current state

- **Web tool: done and live.** A single static page, `index.html`, built from `src/`. It has three tabs:
  - **Keybinds:** uses the File System Access API (`showDirectoryPicker`) to open the WoW folder. It finds every `_version_` install that has a `WTF` folder, then copies `bindings-cache.wtf` between any two installs/accounts (account-wide, plus optional per-character). It can add `SET synchronizeBindings "0"` to the destination `Config.wtf`.
  - **HUD layout:** converts Edit Mode export strings between versions. See "Layout conversion" below.
  - **Backups & restore:** lists every `*.backup-YYYYMMDD-HHMMSS` file the tool made, with Restore and Delete buttons. Restoring backs up the current file first. A backup of "no file before" holds a marker line, and restoring it deletes the file.
- **Next big goal: an in-game addon** that does the same job from inside WoW (export a string in one client, import it in another). The plan is in `docs/addon-plan.md`. Ian cares about **UI layout and keybinds matching**. Putting spells on action bars is **not** a priority.

## Layout of this folder

```
index.html            Built output. This is what GitHub Pages serves. Don't hand-edit; run the build.
README.md             User-facing instructions (shown on the repo page).
src/page.html         Page markup, styles and app script, with two build placeholders.
src/layout.js         Layout string parser/converter. Shared by the page and the tests.
build.js              node build.js > writes index.html from src/ + the Forever default layout.
tests/layout.test.js  node tests/layout.test.js > converter tests against real strings.
reference/layouts/    Real export strings: Ian's Retail layout, the Forever beta default,
                      Ian's final hand-tuned Forever layout, and the first conversion attempt.
reference/screenshots/ Retail vs Forever UI screenshots. Local only (gitignored) because they
                      show other players' names in chat.
docs/                 project-history.md, layout-string-format.md, addon-plan.md
```

## Workflow

For the web tool:

1. Edit files in `src/` (or `README.md`).
2. `node build.js`
3. `node tests/layout.test.js`. All tests must pass.
4. Check the page in a browser if the UI changed.
5. Commit, then push to `main` when Ian says to (or once he approves the change). GitHub Pages updates about a minute after the push.

For addon Lua in `addon/`:

- `luajit -bl <file> NUL` parses a file and prints nothing if it's fine. LuaJIT is Lua 5.1, the same dialect WoW uses, so this catches real syntax errors before the game does. It only checks syntax: it can't tell you whether a WoW API exists.

`node build.js` rewrites `index.html`, so check `git diff` afterwards. Note the byte count it prints is one less than the file size, because `index.html` contains one non-ASCII character (`·`). That's normal, not a build problem.

## Tools installed

Installed on Ian's PC on 2026-09-24, with his go-ahead, via winget:

- **Node.js** 24.19.0 LTS (`C:\Program Files\nodejs`) for the build and tests
- **Python** 3.13.15 (`%LOCALAPPDATA%\Programs\Python\Python313`)
- **LuaJIT** 2.1 (`%LOCALAPPDATA%\Programs\LuaJIT\bin`) for syntax-checking addon Lua

A shell started before these were installed won't have them on `PATH`. In PowerShell, reload it with:

```
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
```

Git runs on Ian's PC with his own GitHub sign-in (Git Credential Manager). Never ask him to paste a token into chat. Commits are authored as `ianmcameron86 <ianmcameron86@gmail.com>`, set repo-locally to match the commits Ian made through the GitHub web UI.

## Layout conversion (the key idea)

Edit Mode strings differ between versions: the header, the list of systems (UI elements), and some settings. So don't translate one format into another directly. Instead, **start from a string exported from the destination version** and copy onto it:
- **Positions:** for every system that exists in both, copy the source's position only if the source moved it (`isInDefaultPosition == 0`).
- **Settings:** copy the source's settings when the setting keys match (or one list is a prefix of the other).
- **Missing systems:** systems only in the destination keep their defaults. Systems only in the source are dropped and reported.

This worked on the real Forever beta, and a Retail > Forever > Retail round trip returns the original string exactly. Format notes are in `docs/layout-string-format.md`.

Known gaps:
- Anchors to frames that differ between versions can land oddly. For example, Retail anchors the main bar to `SecondaryStatusTrackingBarContainer`, and Forever's XP bar is much wider, so the bar shifted right.
- Some systems have different default positions per version. Forever's default micro menu sits inside the bar art, while Retail's is bottom right.
- Users may need small nudges in Edit Mode afterwards. The page tells them this.

## Facts learned (verified in-game on Ian's PC)

- **Install folders:** the WoW Forever beta installs as `_classic_beta_`, so it runs on the **Classic client branch**. Retail is `_retail_`. Ian's install is at `D:\BattleNet\World of Warcraft`.
- **Where keybinds live:** Ian's Retail keybinds were **account-wide**, in `WTF\Account\<ACCOUNT>\bindings-cache.wtf`. His character folders had no `bindings-cache.wtf`.
- **Keybinds carry over by file copy:** copying Retail's `bindings-cache.wtf` into the Forever beta account folder worked. All keys showed correctly on the bars.
- **Layout import works:** the converted Retail layout imported into Forever without errors. Ian then hand-tuned it (`reference/layouts/forever-beta-ian-final.txt`).
- **Bar slots are server-side:** spells in action bar slots are saved on the server, not in the files, so file copying can't move them.
- **Brave:** it disables the File System Access API by default (`brave://flags/#file-system-access-api`). The page detects Brave and explains this. Firefox and Safari can't open folders at all.

## How Ian likes to work

- **Keep it short and plain:** concise, no filler, and plain language in anything players will read.
- **Verify, don't assume:** read the real files and data rather than guessing. Say clearly what was verified and what is inference, especially about WoW Forever, which is new and may differ from Retail or Classic.
- **Test before handing over:** build and test before you say something is done, and don't claim anything was checked in-game unless Ian confirmed it.
- **Ask before big or one-way changes:** anything hard to undo on his PC or the repo. Always back up files before replacing them. That's a core promise of the tool.
- **He tests in-game himself:** he sends screenshots, so ask him to check things you can't.
