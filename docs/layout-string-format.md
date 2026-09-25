# Edit Mode layout string format (reverse engineered)

This is based on real exports from Retail and the WoW Forever beta. Where it says "likely", that part is inference and hasn't been confirmed.

## Overall shape

Space-separated tokens: a header, then one 10-token entry per system (UI element).

| Version | Header | Meaning |
|---|---|---|
| Retail (Sept 2026) | `2 52` | format version, number of entries |
| Forever beta | `4 0 59` | format version, unknown field (likely layout type), number of entries |

The converter finds the header length by checking which count token matches the number of 10-token entries that follow. It tries 2, 3 and 4.

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

## Frame names seen as relativeTo

- **Retail:** SecondaryStatusTrackingBarContainer, MainActionBar, MultiBarBottomLeft, MinimapCluster, FocusFrame, BuffFrame, MicroButtonAndBagsBar, MicroMenuContainer
- **Forever beta:** MicroMenuContainer, CompactRaidFrameManager, MainActionBar, BagsBar, Minimap
