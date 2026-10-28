# Folder structure

The project is organised around the three things you actually work on, an object, a zone, or a
game mode, and each of those gets one self-contained folder with everything that belongs to it,
code, animation data, mappings, art, palettes, layouts, all together instead of spread out.

Art in particular lives inside the thing it belongs to, so you're never hunting across the repo
for a zone's art separately from the rest of that zone.

```
Objects/                  every object: code + anim + maps + art
Levels/                    every zone & special stage: collision, layouts, palettes, objpos, art, blocks, chunks
Modes/               every game mode: zone, title, special stage, ending, ...
Libraries/                shared engine code
Sound/                    music, sound effects and the sound driver
sonic.asm                 main source; the include/binclude statements that reference everything
```

---

## Objects

One folder per object type: badnik, bosses, global, effects misc, holds each objects code, animation data, mappings
and art:

```
Objects/Badniks/
    Crabmeat.asm          object code
    Animations/Crabmeat.asm                 animation script
    Mappings/Crabmeat.asm                 sprite mappings
    Cells/Crabmeat.nem            art
```

Every object lives here without exception, badniks, bosses, the title screen and ending objects,
the special stage objects, all of it. If it has an object ID, this is where you look, so you
never have to guess which tree it might be filed under instead.

That matters most for objects shared between zones. Crabmeat shows up in both Green Hill and
Spring Yard, Caterkiller in both Marble and Scrap Brain, and filing those under a zone would mean
either duplicating them or picking one zone arbitrarily to own them, neither of which is great.

`Objects/shared/` holds the subroutines objects call into (`sub SolidObject.asm`,
`sub AnimateSprite.asm`, and so on), the mapping macros, and any art that doesn't belong to one
specific object. `Objects/shared/Boss/` holds the Eggman mappings, animation and art that every
boss builds its own code on top of.

---

## Zones

One folder per zone, holding everything that defines it:

```
Zones/GHZ/
    Cells/                  zone art
    Blocks.eni              16x16 block mappings
    Chunks.kos              256x256 chunk mappings
    Collision.bin           collision index
    Act */Demo.asm          credits demo input data
    Act */Layouts.bin       foreground and background level layouts
    Act */Objects.bin       object placement
    Act */Start Position    Sonic's starting positions
    Palettes/               zone palettes and palette cycles
```

Zones are Green Hill, Labyrinth, Marble, Star Light, Spring Yard and Scrap Brain.

### Act numbering

Two acts aren't quite what their names suggest, which is worth flagging so it doesn't trip
anyone up later. What the title card calls Scrap Brain Act 3 is internally Labyrinth Act 4, and
Final Zone is internally Scrap Brain Act 3:

```
id_LZ_act4  = $0103    the act presented as Scrap Brain 3
id_FZ       = $0502    Final Zone, the real Scrap Brain 3
```

So Final Zone doesn't get a folder of its own. Since it's really Scrap Brain Act 3, its object
placement and start position just sit alongside the other Scrap Brain acts, as `fz.bin` in
`Zones/Scrap Brain Zone/objpos/` and `startpos/`. No layout, blocks, chunks or palette of its
own, it borrows Scrap Brain's for all of that.

The filenames still follow the player-facing names though, since that's what the ROM's own data
and code labels use too, things like `Level_SBZ3`, `ObjPos_FZ`, `sbz3.bin`, `fz.bin`.
`_Constants.asm` defines both IDs with their internal values, and `Libraries/LevelLayoutLoad.asm`
is where the two get special-cased.

`Zones/Collision/` holds the cross-zone stuff, the collision arrays and angle map every zone uses.

---

## Game Modes

One assmebly file per game mode, `Zone`, `SEGA`, `Title Screen`, `Special Stage`,
`Continue Screen` and `Ending`.

```
Modes/
    Title Screen.asm    game mode code
    End Cutscene.asm    game mode code
    Cells/              art 
    Mappings/           block mappings
    Palettes/           palettes
    Palettes/Cycle/      palette cycles
    Maps/               foreground/background tilemaps
```

`sonic.asm` keeps the game mode table plus the startup, interrupt and main loop code, and pulls
the modes in as includes in the order the ROM expects. That order has to stay put, since it's
what puts the code at the addresses the game actually jumps to.

---

## What stayed where it was

- `Libraries/`, engine code that doesn't belong to any single zone or object: level drawing,
  layer deformation, pattern load cues, palette fading, the object pointer table, HUD updating.
- `Sound/`, the sound driver, its RAM definitions, the music and the sound effects.
- `sonic.asm`, the main source of the game. Every `include` and `binclude` 
  statement still lives in this file, in ROM order, only the paths changed.
- `_Fixed Binaries/`, optional replacement files for bugs the `FixBugs` flag can't patch. It
  mirrors the layout above, so each replacement sits at the path it'd occupy in the project
  proper.

HUD ends up split on purpose here. `Cards/HUD/` holds object 21 with its mappings and art,
while `Libraries/HUD Update.asm` stays with the engine, the object does nothing other than
render the formatted data, meanwhile the update routine handles the BCD for numerics and
various bonuses, such as gaining a life after collecting X rings.

---

## Conventions

Art goes straight in `Cells/`. The file extension already tells you the compression, `.nem` is
Nemesis, `.unc` is uncompressed, `.kos` is Kosinski, so there's no need for a separate folder per
format on top of that. Mappings follow the same idea, `.eni` for Enigma.
