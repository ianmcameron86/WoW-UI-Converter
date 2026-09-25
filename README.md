# WoW Settings Transfer

Copy your keybinds and HUD layout from the World of Warcraft version you're used to into any other one: Retail, WoW Forever, Classic, betas and PTRs. It works in any direction.

**Use it here:** open `index.html` in Chrome or Edge on a desktop computer, or use the hosted link on this repo's page.

Everything runs in your browser. Nothing is uploaded anywhere, and there's nothing to install.

## Keybinds

1. Close World of Warcraft (all versions).
2. Click **Choose folder** and pick your World of Warcraft folder, the one that contains `_retail_`, `_classic_` and so on. Allow the browser to view and edit files there.
3. On the **Keybinds** tab, pick the game version and account to copy from, then the one to copy to.
4. Optional: if a character has its own keybinds, pick it and a destination character.
5. Click **Copy keybinds**, then launch the game.

Leave **Stop the destination game from replacing these keybinds** ticked. Otherwise WoW may load its server copy of your old keybinds over the new ones.

Only keybinds carry over. Spells on your action bars are saved on Blizzard's servers, so you'll need to drag those onto your bars again. Keybinds for actions that don't exist in the other version are ignored.

## HUD layout

This works between versions that have Edit Mode (Esc > Edit Mode). Classic Era doesn't have Edit Mode, so it has no layout to copy.

1. In the game you're copying **from**, open Edit Mode, choose your layout, and **Export** it.
2. In the game you're copying **to**, export any layout (the default preset is best). For the WoW Forever beta you can click **Use the WoW Forever beta default** instead.
3. Paste both into the **HUD layout** tab and click **Convert layout**.
4. Copy the result and use **Import** in Edit Mode in the destination game.

A few elements might need a small nudge afterwards, usually the main action bar or XP bar, because some frames are different between versions.

## Backups and restore

Before the tool changes any file, it saves the old one next to it with the date and time in its name, for example `bindings-cache.wtf.backup-20260924-204131`.

To undo a change, open the **Backups & restore** tab, find the backup and click **Restore**. Restoring also backs up the file it replaces, so you can switch back again. Close the game before restoring.

Layout imports don't need backups. The game saves an imported layout as a new layout, and your existing ones stay in Edit Mode.

## Where WoW keeps these files

- Account keybinds: `World of Warcraft\<version>\WTF\Account\<ACCOUNT>\bindings-cache.wtf`
- Character keybinds: `...\WTF\Account\<ACCOUNT>\<Realm>\<Character>\bindings-cache.wtf`
- Game settings: `...\WTF\Config.wtf`

If a version or account doesn't show up, log into that version once and log out normally so WoW creates its folders.

## Notes

- Needs Chrome or Edge on desktop, because they're the only browsers that let a web page open a folder. The HUD layout tab works in any browser.
- This is a fan-made tool and is not affiliated with or endorsed by Blizzard Entertainment.
