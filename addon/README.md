# Addons

## WoWUIConverterProbe

A throwaway, read-only addon. It reports which keybind and Edit Mode functions a
client has, so the real addon can be built against what's actually there instead
of guesswork. It changes nothing: no layout is saved, no keybind is set.

### Install

Copy the `WoWUIConverterProbe` folder into each client's AddOns folder:

```
D:\BattleNet\World of Warcraft\_retail_\Interface\AddOns\WoWUIConverterProbe\
D:\BattleNet\World of Warcraft\_classic_beta_\Interface\AddOns\WoWUIConverterProbe\
```

Each folder should end up holding `WoWUIConverterProbe.toc` and `probe.lua`.

If the game is already running, log out to the character select screen.

### Run it

1. At character select, click **AddOns** and tick **Load out of date AddOns**.
   The interface numbers in the `.toc` are guesses, which is part of what the
   probe is there to find out, so expect it to show as out of date.
2. Log in. You should see a green "probe loaded" line in chat.
3. Type `/wucprobe full`
4. A window opens with the report. Click the text, Ctrl+A, Ctrl+C, and paste it
   back to Claude.

`/wucprobe` on its own gives the shorter report, without the full keybind list
and layout string.

The report is also written to SavedVariables when you log out, so you can send
this file instead of pasting:

```
_retail_\WTF\Account\<ACCOUNT>\SavedVariables\WoWUIConverterProbe.lua
```

### Do it in both clients

Run it in Retail **and** in the Forever beta. Comparing the two reports is the
whole point: the differences decide how the real addon has to work.

### Uninstall

Delete the `WoWUIConverterProbe` folder from each `Interface\AddOns`.
