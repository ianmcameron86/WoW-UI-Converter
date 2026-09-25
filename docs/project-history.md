# Project history

A summary of the chat where this project started (Sept 24, 2026), in order.

## 1. Converting Ian's Retail layout for the Forever beta

- **The problem:** Ian exported his Retail Edit Mode layout and tried to import it into the WoW Forever beta. The import failed with an error.
- **What differed:** comparing his Retail string with the Forever beta default showed:
  - the header was different (Retail `2 52`, Forever `4 0 59`)
  - Forever had 8 systems Retail didn't (25, 26 index 0 and 1, 27, 28, 29 index 0 to 2)
  - Retail had one system Forever didn't (26 -1)
  - the micro menu (13) had one extra setting in Retail
- **Two versions sent:**
  - `converted.txt`: Retail positions and settings on top of the Forever default. The micro menu was moved by hand to the bottom right to match Retail.
  - `converted_safe.txt`: the same, but three bars that anchored to frames Forever's string never mentions were pinned to fixed screen positions instead.
- **Result:** the first version imported. Remaining issues:
  - only one action bar row showed (bars 2 to 5 are turned on in the game options, not by the layout)
  - the main bar was off-center because Forever's XP bar is wider
  - the gryphon end caps still showed
  - the XP bar was full width
- **Ian's fixes:** he finished it in Edit Mode. His final string is `reference/layouts/forever-beta-ian-final.txt`. Compared with the safe version, he:
  - hid the gryphons (system 26 settings `#$`)
  - narrowed the XP bar (15 0 `&%`)
  - moved the objective tracker to 777, 0
  - moved the raid frames up (3 4 y 0)

## 2. Keybinds

- **Where the files were:** Ian's Retail keybinds were account-wide at `_retail_\WTF\Account\<ACCOUNT>\bindings-cache.wtf`. His character folders had none.
- **The copy:** he copied that file into `_classic_beta_\WTF\Account\<ACCOUNT>\`. It worked, and all his keys showed on the beta bars.
- **The server copy:** `SET synchronizeBindings "0"` in `Config.wtf` stops the server copy from overwriting the local file. This was suggested as a fallback. Whether Forever needs it isn't confirmed.

## 3. Building the tool

- **App or addon:** we weighed a desktop app against an in-game addon. Ian wanted a simple "pick your WoW folder" UI first, working in both directions. We built a single-file web page using the File System Access API: no install, runs in Chrome/Edge.
- **What he added:**
  - any-to-any between Classic, Forever and Retail
  - a backup of every replaced file
  - an easy restore, which became the Backups & restore tab
- **Browser tests:** the page was tested in headless Chromium against a mock WoW folder, covering:
  - Classic Era > Forever, including character keybinds
  - Retail > Forever
  - Forever > Retail
  - Retail > Classic Era
  - restore, and a restore that removes a file added with no previous file
  - delete
- **Not yet tested:** the tool hasn't been run against Ian's real WoW folder. Ask him to try it.

## 4. Publishing

- **Where it lives:** Ian made the GitHub account `ianmcameron86` and the repo `WoW-UI-Converter`, and turned on GitHub Pages (main, root). The site loads.
- **Brave fix:** Ian uses Brave, which blocks folder access by default. The page now detects Brave and shows the `brave://flags` fix, and the README covers browser support.
- **Why it moved to this PC:** pushing from the cloud chat was blocked by that environment's git proxy. Work moved to Claude Code on Ian's personal PC, which is this folder.
