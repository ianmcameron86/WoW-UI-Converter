# Edit Mode layout string format (reverse engineered)

This is based on real exports from Retail and the WoW Forever beta. Where it says "likely", that part is inference and hasn't been confirmed.

## Overall shape

Space-separated tokens: a header, then one 10-token entry per system (UI element).

| Version | Header | Meaning |
|---|---|---|
| Retail (Sept 2026) | `2 52` | format version, number of entries |
| Classic Burning Crusade | `2 31` | format version, number of entries |
| Forever beta | `4 0 59` | format version, unknown field (likely layout type), number of entries |

The converter finds the header length by checking which count token matches the number of 10-token entries that follow. It tries 2, 3 and 4.

Classic BC uses the same format version as Retail and the same 10-token entries. It just has fewer systems, because it has fewer UI features. Nothing in the converter needed changing to support it, which was confirmed against a real BC export.

## Entry (10 tokens)

`system index isInDefaultPosition point relativePoint relativeTo offsetX offsetY unknown settings`

| # | Field | Example | Notes |
|---|---|---|---|
| 1 | system | `3` | System type ID (list below) |
| 2 | index | `0` | Which instance, for example action bar 1 vs 2. `-1` means the system has only one. |
| 3 | isInDefaultPosition | `0` | `1` = default position, `0` = moved by the user |
| 4 | point | `0` | Anchor point on this frame |
| 5 | relativePoint | `0` | Anchor point on the relative frame |
| 6 | relativeTo | `UIParent` | Frame name, no spaces |
| 7, 8 | offsetX, offsetY | `537.5 -622.5` | In UI units. With Ian's settings the screen was about 1920x1080 units. |
| 9 | unknown | `-1` | Always `-1` so far |
| 10 | settings | `##$$%/` | Encoded settings, see below |

**Anchor points:** 0 TOPLEFT, 1 TOP, 2 TOPRIGHT, 3 LEFT, 4 CENTER, 5 RIGHT, 6 BOTTOMLEFT, 7 BOTTOM, 8 BOTTOMRIGHT. This was checked against screenshots.

## Settings string

Pairs of characters: a key then a value, each encoded as `charCode - 35` (`#` = 0, `$` = 1, `%` = 2 ...). Keys can repeat inside one string, so keep the pairs in order rather than treating them as a map. A few strings are a single character (for example `#`). Those are copied as they are.

## System IDs

Shared by both versions (likely):
0 action bars, 1 cast bar, 2 minimap, 3 unit frames (index 0 player, 1 target, 2 focus, 3 party, 4 raid, 5 boss, 6 arena, 7 pet), 4 encounter bar, 5 extra abilities, 6 auras, 7 talking head, 8 chat, 9 vehicle leave button, 10 loot, 11 tooltip, 12 objective tracker, 13 micro menu, 14 bags, 15 status (XP/rep) bars, 16 to 24 misc (durability, timers, vehicle seats, archaeology, cooldown viewer, personal resource, encounter events, damage meter ...).

Only one version:
- **Retail:** 26 -1 (unknown, settings `#(`)
- **Forever beta:** 25 -1, 26 0/1 (gryphon end caps attached to MainActionBar and BagsBar; `#$` hides them), 27 -1 (attached to Minimap), 28 -1, 29 0-2

**Classic Burning Crusade** has only 0, 1, 2, 3, 5, 6, 8, 9, 13, 14, 15, 16, 18 and 24, a subset of both the others. It has no encounter bar (4), talking head (7), loot (10), tooltip (11) or objective tracker (12), and none of the higher Retail or Forever systems. Within unit frames (3) it has 0 player, 1 target, 2 focus, 3 party, 4 raid and 7 pet, but no 5 boss or 6 arena.

So **BC to anything loses nothing**, and **anything to BC drops the systems BC has no room for**, which the converter reports.

BC's Edit Mode has an "Advanced Options" panel with checkboxes (Pet Frame, Raid Frames, Cast Bar, Pet Bar, Possess Bar, Status Bar 2 and so on). Those do **not** add or remove entries: in Ian's export, unticked elements such as Pet Frame and Raid Frames still had entries (3 7 and 3 4). They look like visibility settings inside the settings string. That's inference from one export, not confirmed.

## Frame names seen as relativeTo

- **Retail:** SecondaryStatusTrackingBarContainer, MainActionBar, MultiBarBottomLeft, MinimapCluster, FocusFrame, BuffFrame, MicroButtonAndBagsBar, MicroMenuContainer
- **Forever beta:** MicroMenuContainer, CompactRaidFrameManager, MainActionBar, BagsBar, Minimap
- **Classic BC:** MainMenuBarArtFrame, StatusTrackingBarManager, PlayerFrame, TargetFrame, PartyFrame, MinimapCluster, BuffFrame, CompactRaidFrameManager

**Classic BC anchors to unit frames more than the others do.** Of the 9 elements Ian had moved, 6 hang off PlayerFrame, TargetFrame, PartyFrame, MinimapCluster or BuffFrame rather than UIParent. Those anchors are carried over as-is, so they are the most likely things to land oddly:

| Converting | Elements whose anchor the destination's own string never mentions |
|---|---|
| BC to Retail | 3:2 TargetFrame, 3:3 PlayerFrame, 9:-1 PartyFrame, 16:-1 PlayerFrame |
| BC to Forever | the same four, plus 6:0 MinimapCluster and 6:1 BuffFrame |

Retail does have PlayerFrame and TargetFrame, so BC to Retail is probably fine. Forever's own export uses `Minimap`, not `MinimapCluster`, so that one is the most suspect. Not yet checked in-game.
