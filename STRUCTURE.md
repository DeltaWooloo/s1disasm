# Folder structure

The project is organised around the three things you actually work on, an object, a zone, or a
game mode, and each of those gets one self-contained folder with everything that belongs to it,
code, animation data, mappings, art, palettes, layouts, all together instead of spread out.

Art in particular lives inside the thing it belongs to, so you're never hunting across the repo
for a zone's art separately from the rest of that zone.

```
Objects/                  every object: code + anim + maps + art
Zones/                    every zone: collision, layouts, palettes, objpos, art, blocks, chunks
Game Modes/               every game mode: level, title, special stage, ending, ...
Libraries/                shared engine code
Sound/                    music, sound effects and the sound driver
sonic.asm                 main source; the include/binclude statements that reference everything
```

---

## Objects

One folder per object, named `<ID> <name>`, holding that object's code, animation data, mappings
and art:

```
Objects/1F Badnik - Crabmeat/
    1F Badnik - Crabmeat.asm          object code
    anim/Crabmeat.asm                 animation script
    maps/Crabmeat.asm                 sprite mappings
    art/Enemy Crabmeat.nem            art
```

The hex object ID stays in the folder name so folders sort in ID order and cross-reference
cleanly against `Libraries/Object Pointers.asm`. Where one source file implements more than one
ID, every ID it covers goes in the name too, so `Objects/1E, 20 Badnik - Ball Hog and
Cannonball/` rather than picking just one.

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
Zones/Green Hill Zone/
    art/                zone art
    blocks/GHZ.eni      16x16 block mappings (was map16/)
    chunks/GHZ.kos      256x256 chunk mappings (was map256/)
    collision/GHZ.bin   collision index
    demos/              intro and credits demo input data
    layouts/            foreground and background level layouts
    objpos/             object placement
    palettes/           zone palettes and palette cycles
    startpos/           Sonic's starting positions
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

`Zones/shared/` holds the cross-zone stuff, the collision arrays and angle map every zone uses,
plus the unused demo.

---

## Game Modes

One folder per game mode, `Level`, `Sega Screen`, `Title Screen`, `Special Stage`,
`Continue Screen` and `Ending`, each with its own code, art, palettes and layouts, instead of
being scattered across the old `tilemaps`, `sslayout` and `artunc` folders like before:

```
Game Modes/Special Stage/
    Special Stage.asm           game mode code
    Special Stage Rendering.asm layout drawing, mappings and VRAM pointers
    art/            stage art
    demos/          the intro demo that plays in the special stage
    layouts/        stage layouts (was sslayout/)
    maps/           block mappings
    palettes/       palettes and palette cycles
    startpos/       per-stage starting positions
    tilemaps/       background tilemaps
```

Each mode's code sits at the root of its own folder, same as an object's code does:

```
Game Modes/Level/Level.asm                     normal levels and demo mode
Game Modes/Sega Screen/Sega Screen.asm
Game Modes/Title Screen/Title Screen.asm        also holds the level select
Game Modes/Special Stage/Special Stage.asm
Game Modes/Continue Screen/Continue Screen.asm
Game Modes/Ending/Ending.asm
Game Modes/Ending/Credits.asm
Game Modes/Ending/Try Again and End.asm
```

`sonic.asm` keeps the game mode table plus the startup, interrupt and main loop code, and pulls
the modes in as includes in the order the ROM expects. That order has to stay put, since it's
what puts the code at the addresses the game actually jumps to.

---

## What stayed where it was

- `Libraries/`, engine code that doesn't belong to any single zone or object: level drawing,
  layer deformation, pattern load cues, palette fading, the object pointer table, HUD updating.
- `Sound/`, the sound driver, its RAM definitions, the music and the sound effects.
- `sonic.asm`, `_Constants.asm`, `_Variables.asm`, `Macros.asm`, `MacroSetup.asm`, the main
  source and its supporting definitions. Every `include` and `binclude` statement still lives in
  `sonic.asm`, in ROM order, only the paths changed.
- `_Fixed Binary Files/`, optional replacement files for bugs the `FixBugs` flag can't patch. It
  mirrors the layout above, so each replacement sits at the path it'd occupy in the project
  proper.

HUD ends up split on purpose here. `Objects/21 HUD/` holds object 21 with its mappings and art,
while `Libraries/HUD Update.asm` stays with the engine, since the object and the routine that
updates the display are genuinely two different things even if they're related.

---

## Conventions

Art goes straight in `art/`. The file extension already tells you the compression, `.nem` is
Nemesis, `.unc` is uncompressed, `.kos` is Kosinski, so there's no need for a separate folder per
format on top of that. Mappings follow the same idea, `.eni` for Enigma.

Object folders are `<ID> <name>`, with every ID the file implements, matching the source
filename inside.

Zone and game mode folders get written out in full, `Green Hill Zone`, `Title Screen`, never
abbreviated. The abbreviations only survive inside filenames, where they came from the original
data anyway (`blocks/GHZ.eni`, `objpos/ghz1.bin`).