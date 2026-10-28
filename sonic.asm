;  =========================================================================
; |           Sonic the Hedgehog Disassembly for Sega Mega Drive            |
;  =========================================================================
;
; Disassembly created by Hivebrain
; thanks to drx, Stealth and Esrael L.G. Neto
; ---------------------------------------------------------------------------
; NOTE:
; Set your editor's tab width to 8 characters wide for viewing this file.

; ===========================================================================
; ASSEMBLY OPTIONS:

Revision = 1
; 	| If 0, build the original version of the game, dubbed REV00
; 	| If 1, build the later version, dubbed REV01, which includes various bugfixes and enhancements
; 	| If 2, build the hacked version from Sonic Mega Collection, dubbed REVXB,
;	|       which (sloppily) fixes the infamous "spike bug" -- not recommended

FixBugs = 0
;	| If 1, enables various bugfixes across the game and sound driver
;	|       (see also the "_Fixed Binary Files" folder, and FixMusicAndSFXDataBugs)

CheatsEnabled = 0
;	| If 1, all in-game cheats (Level Select, Debug Mode, Slow-Motion, Japanese Credits)
;	|       will be enabled by default, without requiring any title screen button inputs

AllOptimizations = 0
;	| If 1, enables all optimizations
SkipChecksumCheck = 0|AllOptimizations
;	| If 1, disables the slow bootup checksum calculation
ZeroOffsetOptimization = 0|AllOptimizations
;	| If 1, makes a handful of zero-offset instructions smaller
PaddingOptimization = 0|AllOptimizations
;	| If 1, removes about 3 KB of various superfluous padding

EnableSRAM = 0
;	| If 1, enable SRAM support
BackupSRAM = 1
;	| 0 = no saving (read-only SRAM); 1 = allow saving
AddressSRAM = 3
;	| 0 = odd+even; 2 = even only; 3 = odd only
;	| (odd only is the most common setting)

ZoneCount = 6
;	| Used for the "zonewarning" macro. Do not change, unless more zones get added.
;	| Discrete zones are: GHZ, LZ, MZ, SLZ, SYZ, and SBZ

; ===========================================================================
; AS-specific macros and assembler settings
	cpu 68000
	include "Define/Macros (Assembler Specifc).asm" 

; ===========================================================================
; Simplifying macros and functions
	include	"Define/Macros (General).asm"

; ===========================================================================
; Equates section - Names for constants
	include	"Define/Constants.asm"

; ===========================================================================
; Equates section - Names for variables
	include	"Define/Variables.asm"

; ===========================================================================
; Expressing sprite mappings and DPLCs in a portable and human-readable form
SonicMappingsVer = 1
SonicDplcVer = 1
	include	"Define/Macros (Sprites).asm"

; ===========================================================================
; Start of ROM
	include "Routines/System/Header.asm"

; ---------------------------------------------------------------------------
; Entry point for the game on boot or soft-reset
; (This section from a standard Mega Drive devkit library)
; ---------------------------------------------------------------------------
	include "Routines/System/Initalize.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Proper game entry point for Sonic the Hedgehog after initialization
; ---------------------------------------------------------------------------
	include "Routines/System/Game Mode.asm"

	include "Routines/System/Error Handler.asm"
	include "Routines/System/Vertical Interrupt.asm"
	include "Routines/System/Horizontal Interrupt.asm"
	include "Routines/System/Joypad.asm"
	include "Routines/System/VDP.asm"
	include "Routines/System/Load DAC and Sounds.asm"
	include	"Routines/System/Pause.asm"
	include "Routines/System/Load Tilemap.asm"

; ===========================================================================
; >>> Nemesis decompression algorithm, primarily (but not exclusively) used for PLCs
	include	"Routines/Decompression/Nemesis Decompression.asm"

	include "Routines/Pattern Load Cue.asm"
; ===========================================================================
; >>> Other decompression algorithms
	include	"Routines/Decompression/Enigma Decompression.asm"
	include	"Routines/Decompression/Kosinski Decompression.asm"


; ===========================================================================
; >>> Palette logic routines
	include	"Routines/PaletteCycle.asm"
	include	"Routines/Palette Fading.asm" ; includes "PaletteFadeIn", "PaletteFadeOut", "PaletteWhiteIn", and "PaletteWhiteOut"
	
	include "Modes/SEGA Palette.asm"
	include "Routines/Load Palette.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to wait for VBlank routines to complete
; ---------------------------------------------------------------------------

; DelayProgram: <-- old misnomer
; WaitForVBla: <-- old name
WaitForVBlank:
		enable_ints					; enable interrupts so vertical interrupts can occur

.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, loop until it has
		rts						; resume normal operation
; End of function WaitForVBlank

; ===========================================================================
; ---------------------------------------------------------------------------
; >>> Subroutines for generic calculations
; ---------------------------------------------------------------------------
	include	"Routines/Math.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; >>> Routines for Game Modes
; ---------------------------------------------------------------------------
	include	"Modes/SEGA.asm"
	include	"Modes/Title Screen.asm"
	include	"Modes/Zone.asm"
	include	"Modes/Special Stage.asm"
	include	"Modes/Continue Screen.asm"
	include	"Modes/End Cutscene.asm"
	include	"Modes/Credits.asm"
	include	"Modes/End Screen.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; >> END OF MAIN GAME LOGIC - Everything below this point is file includes <<
; ---------------------------------------------------------------------------
; ===========================================================================

; Where possible, includes to _maps and _anim were appended to the _incObj
; file includes themselves. However, in some cases this wasn't possible,
; as the developers weren't very consistent with the placement, especially
; during the early stages of production. Those includes are still here.

; ===========================================================================
; >>> Level rendering, loading, and updating
		include	"Routines/LevelSizeLoad & BgScrollSpeed.asm" ; merged with "LevelSizeLoad & BgScrollSpeed (JP1).asm"
	if Revision=0
		include	"Routines/DeformLayers (REV00).asm"
		include	"Routines/Level Drawing (REV00).asm"
	else
		include	"Routines/DeformLayers (REV01).asm"
		include	"Routines/Level Drawing (REV01).asm"
	endif
		include	"Routines/LevelLayoutLoad.asm" ; includes LevelDataLoad, LevelLayoutLoad, and LevelLayoutLoad2

		include	"Routines/DynamicLevelEvents.asm"


; ===========================================================================
; >>> Various level objects
		include	"Objects/Zone/GHZ/Bridge.asm"
		include	"Objects/Zone/Shared/Swinging Platform and Spike.asm" ; includes "MvSonicOnPtfm" subroutine
		include	"Objects/Zone/GHZ/Spiked Pole Helix.asm"
		include	"Objects/Zone/Shared/Platform.asm"
		include	"Objects/Unused/GHZ Ball.asm" ; prototype leftover
Map_GBall:	include	"Objects/Unused/Mappings/GHZ Ball.map"
		include	"Objects/Zone/Shared/Collapsing Geometry.asm" ; includes "SlopeObject_AssumeStoodOn" subroutine
		include	"Objects/Zone/Shared/Scenery.asm"
		include	"Objects/Unused/Switch.asm"
		include	"Objects/Zone/SBZ/Small Door.asm"
		include	"Objects/shared/sub SolidWall.asm"


; ===========================================================================
; >>> Badniks, explosions, and Badnik-related objects
		include	"Objects/Badniks/Ball Hog and Cannonball.asm"
		include	"Objects/Unused/Small Explosion.asm"
		include	"Objects/Effects/Explosion.asm"
		include	"Objects/Badniks/Animations/Ball Hog.ani"
Map_Hog:	include	"Objects/Badniks/Mappings/Ball Hog.map"
Map_UnkExplode:	include	"Objects/Unused/Mappings/Small Explosion.map"
		include	"Objects/Effects/Mappings/Explosion.map"
		include	"Objects/Effects/Animal and Points.asm"
		include	"Objects/Badniks/Crabmeat.asm"
		include	"Objects/Badniks/Buzz Bomber and Missile.asm"


; ===========================================================================
; >>> Rings
		include	"Objects/Global/Ring.asm"
		include	"Objects/Global/Giant Ring.asm"
		include	"Objects/Global/Animations/Ring.ani"
Map_Ring:   if Revision=0
		include	"Objects/Global/Mappings/Ring (REV00).map"
	    else
		; REV01 added an extra blank frame, possibly to mitigate
		; rings occasionally popping up in the sign post sparkles
		include	"Objects/Global/Mappings/Ring (REV01).map"
	    endif
Map_GRing:	include	"Objects/Global/Mappings/Giant Ring.map"
Map_Flash:	include	"Objects/Global/Mappings/Giant Ring Flash.map"


; ===========================================================================
; >>> Monitors
		include	"Objects/Global/Monitor.asm"


; ===========================================================================
; >>> Title screen objects (includes AnimateSprite)
		include	"Objects/Cards/Title Screen Pieces.asm"


; ===========================================================================
; >>> More Badniks and level objects
		include	"Objects/Badniks/Chopper.asm"
		include	"Objects/Badniks/Jaws.asm"
		include	"Objects/Badniks/Burrobot.asm"
		include	"Objects/Zone/MZ/Large Grassy Platforms and Burning Grass.asm"
Map_Fire:	include	"Objects/Zone/Shared/Mappings/Fireball.map"
		include	"Objects/Zone/MZ/Large Green Glass Blocks.asm"
		include	"Objects/Zone/MZ/Chained Stompers.asm"
		include	"Objects/Unused/MZ Sideways Stomper.asm"
Map_CStom:	include	"Objects/Zone/MZ/Mappings/Chained Stompers.map"
Map_SStom:	include	"Objects/Unused/Mappings/MZ Sideways Stomper.map"
		include	"Objects/Zone/Shared/Button.asm"
		include	"Objects/Zone/Shared/Pushable Blocks.asm"


; ===========================================================================
; >>> Title card objects
		include	"Objects/Cards/Title Cards.asm"
		include	"Objects/Cards/Game Over Text.asm"
		include	"Objects/Cards/Got Through Card.asm"
		include	"Objects/Cards/Special Stage Results.asm"
		include	"Objects/Cards/Mappings/Title Cards.map" ; includes "Map_Card", "Map_Over", "Map_Got", and "Map_SSR"
Map_SSRC:	include	"Objects/Cards/Mappings/Emeralds (Results).map"


; ===========================================================================
; >>> More level objects
		include	"Objects/Global/Spike.asm"
		include	"Objects/Zone/GHZ/Purple Rock.asm"
		include	"Objects/Zone/GHZ/Waterfall Sound.asm"
Map_PRock:	include	"Objects/Zone/GHZ/Mappings/Purple Rock.map"
		include	"Objects/Zone/Shared/Breakable Wall.asm" ; includes SmashObject


; ===========================================================================
; Subroutines to run, render, and update objects
		include	"Routines/ExecuteObjects.asm"
		include	"Routines/Object Pointers.asm" ; includes Obj_Index
		include	"Objects/shared/sub ObjectFall & SpeedToPos.asm"
		include	"Objects/shared/sub DisplaySprite.asm"
		include	"Objects/shared/sub DeleteObject.asm"
		include	"Routines/BuildSprites.asm"
		include	"Objects/shared/sub ChkObjectVisible.asm"
		include	"Routines/ObjPosLoad.asm"
		include	"Objects/shared/sub FindFreeObj.asm"


; ===========================================================================
; >>> More level objects
		include	"Objects/Global/Spring.asm"
		include	"Objects/Badniks/Newtron.asm"
		include	"Objects/Badniks/Roller.asm"
		include	"Objects/Zone/GHZ/Edge Walls.asm"
		include	"Objects/Zone/Shared/Fireball and Maker.asm"
		include	"Objects/Zone/SBZ/Flamethrower.asm"
		include	"Objects/Zone/MZ/Bricks.asm"
		include	"Objects/Zone/SYZ/Search Light.asm"
		include	"Objects/Zone/SYZ/Bumper.asm"
		include	"Objects/Global/Signpost.asm" ; includes "GotThroughAct" subroutine
		include	"Objects/Zone/MZ/Lava Geyser and Maker.asm"
		include	"Objects/Zone/MZ/Wall of Lava.asm"
		include	"Objects/Zone/MZ/Invisible Lava Tag.asm"
		include	"Objects/Zone/MZ/Animations/Lava Geyser.ani"
		include	"Objects/Zone/MZ/Animations/Wall of Lava.ani"
Map_Geyser:	include	"Objects/Zone/MZ/Mappings/Lava Geyser.map"
Map_LWall:	include	"Objects/Zone/MZ/Mappings/Wall of Lava.map"
		include	"Objects/Badniks/Moto Bug.asm" ; includes "Objects/shared/sub RememberState.asm" subroutine
		include	"Objects/Unused/Splats.asm" ; this was Splats in the prototype
		include	"Objects/Badniks/Yadrin.asm"
		include	"Objects/shared/sub SolidObject.asm"
		include	"Objects/Zone/MZ/Smashable Green Block.asm"
		include	"Objects/Zone/Shared/Moving Block.asm"
		include	"Objects/Badniks/Basaran.asm"
		include	"Objects/Zone/Shared/Floating Blocks and Doors.asm"
		include	"Objects/Zone/Shared/Spiked Ball and Chain.asm"
		include	"Objects/Zone/SYZ/Big Spiked Ball.asm"
		include	"Objects/Zone/SLZ/Elevators.asm"
		include	"Objects/Zone/SLZ/Circling Platform.asm"
		include	"Objects/Zone/SLZ/Staircase.asm"
		include	"Objects/Zone/SLZ/Foreground Pylon.asm"
		include	"Objects/Zone/LZ/Water Surface.asm"
		include	"Objects/Zone/LZ/Breakable Pole.asm"
		include	"Objects/Zone/LZ/Flapping Door.asm"
		include	"Objects/Global/Invisible Barrier.asm"
		include	"Objects/Zone/SLZ/Fan.asm"
		include	"Objects/Zone/SLZ/Seesaw.asm"
		include	"Objects/Badniks/Walking Bomb.asm"
		include	"Objects/Badniks/Orbinaut.asm"
		include	"Objects/Zone/LZ/Harpoon.asm"
		include	"Objects/Zone/LZ/Block.asm"
		include	"Objects/Zone/LZ/Gargoyle.asm"
		include	"Objects/Zone/LZ/Conveyor.asm"
		include	"Objects/Zone/LZ/Air Bubble.asm"
		include	"Objects/Zone/LZ/Waterfall.asm"


; ===========================================================================
; >>> Main Sonic player object
		include	"Objects/Global/Sonic.asm"


; ===========================================================================
; >>> Various unique objects
		include	"Objects/Zone/LZ/Drowning Countdown.asm" ; includes ResumeMusic
		include	"Objects/Effects/Shield and Invincibility.asm"
		include	"Objects/Unused/Special Stage Entry.asm"
		include	"Objects/Zone/LZ/Water Splash.asm"
		include	"Objects/Effects/Animations/Shield and Invincibility.ani"
Map_Shield:	include	"Objects/Effects/Mappings/Shield and Invincibility.map"
		include	"Objects/Unused/Animations/Special Stage Entry.ani"
Map_Vanish:	include	"Objects/Unused/Mappings/Special Stage Entry.map"
		include	"Objects/Zone/LZ/Animations/Water Splash.ani"
Map_Splash:	include	"Objects/Zone/LZ/Mappings/Water Splash.map"


; ===========================================================================
; >>> Collision subroutines for Sonic and other objects
		include	"Objects/Global/Sonic (Ground Collision).asm"
		include	"Objects/shared/sub FindNearestTile & FindFloor & FindWall.asm"
		include "Routines/ConvertCollisionArray (Unused).asm"
		include	"Objects/Global/Sonic (Collision Detection).asm"


; ===========================================================================
; >>> SBZ level objects
		include	"Objects/Zone/SBZ/Rotating Junction.asm"
		include	"Objects/Zone/SBZ/Running Disc.asm"
		include	"Objects/Zone/SBZ/Conveyor Belt.asm"
		include	"Objects/Zone/SBZ/Spinning Platforms and Trapdoors.asm"
		include	"Objects/Zone/SBZ/Saws and Pizza Cutters.asm"
		include	"Objects/Zone/SBZ/Stomper and Sliding Door.asm"
		include	"Objects/Zone/SBZ/Vanishing Platforms.asm"
		include	"Objects/Zone/SBZ/Electrocuter.asm"
		include	"Objects/Zone/SBZ/Spin Platform Conveyor.asm"
		include	"Objects/Zone/SBZ/Girder Block.asm"
		include	"Objects/Zone/SBZ/Teleporter.asm"

; ===========================================================================
; >>> Misc objects
		include	"Objects/Badniks/Caterkiller.asm"
		include	"Objects/Global/Lamppost.asm"
		include	"Objects/Effects/Hidden Points.asm"
		include	"Objects/Cards/Credit Text.asm"


; ===========================================================================
; >>> Bosses and related objects
		include	"Objects/Bosses/Egg Wrecker.asm" ; includes "BossDefeated" and "BossMove" subroutines
		include	"Objects/Bosses/Animations/Eggman.ani"
Map_Eggman:	include	"Objects/Bosses/Mappings/Eggman.map"
Map_BossItems:	include	"Objects/Bosses/Mappings/Boss Items.map"
		include	"Objects/Bosses/Egg Mobile.asm"
		include	"Objects/Bosses/Egg Scorcher.asm"
		include	"Objects/Bosses/Egg Spiker.asm"
		include	"Objects/Bosses/Egg Stinger.asm"
		include	"Objects/Zone/SBZ/Eggman Cutscene and Crumbling Floor.asm"
		include	"Objects/Bosses/Egg Crusher.asm"
		include	"Objects/Global/Prison Capsule.asm"


; ===========================================================================
; >>> Object-to-object touch response handler for Sonic
		include	"Objects/Global/Sonic (Object Reactions).asm"


; ===========================================================================
; >>> Special Stage rendering and objects
		; The following includes "SS_ShowLayout", "SS_AniWallsRings",
		; "SS_FindFreeAnimationSlot", "SS_AniItems", and "SS_Load"
		include	"Modes/Special Stage (Renderer).asm"
Map_SS_Shared:	include	"Levels/Special/Mappings/Shared.asm"
Map_SS_Glass:	include	"Levels/Special/Mappings/Glass.asm"
Map_SS_Up:	include	"Levels/Special/Mappings/UP.asm"
Map_SS_Down:	include	"Levels/Special/Mappings/DOWN.asm"
Map_SS_Chaos:	include	"Levels/Special/Mappings/Chaos Emeralds.asm"
		include	"Objects/Global/Sonic (Special Stage).asm"


; ===========================================================================
; >>> Deleted, blank object that is randomly mixed in here
		include	"Objects/Unused/Animation Test.asm" ; this was an animation test object for Sonic in the prototype


; ===========================================================================
; >>> Subroutine for in-place level animations in VRAM
		include	"Routines/AnimateLevelGfx.asm"


; ===========================================================================
; >>> HUD objects
		include	"Objects/Cards/HUD.asm"
		include	"Objects/shared/sub AddPoints.asm"
		include	"Routines/HUD Update.asm" ; includes "ContScrCounter" subroutine

Art_Hud:	binclude "Objects/Cards/Cells/Numerals.unc" ; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	binclude "Objects/Cards/Cells/Life Numerals.unc" ; 8x8 pixel numbers on lives counter
		even


; ===========================================================================
; >>> Debug Mode
		include	"Objects/shared/DebugMode.asm"


; ===========================================================================
; >>> Level definitions
		include	"Routines/LevelHeaders.asm"
		include	"Routines/Pattern Load Cues.asm"


; ===========================================================================

; ---------------------------------------------------------------------------
; >> END OF PRIMARY INCLUDES - Everything below this point is art includes <<
; ---------------------------------------------------------------------------

		; Nem_SegaLogo has a bunch of padding before it that differs between revisions:
		; - in rev00, it starts at $1DC00, which amounts to $EE bytes
		; - in rev01/rev02, it starts at $1E700, which amounts to $48E bytes
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$200
		if Revision<>0
			dcb.b	$300,$FF
		endif
	endif

; ===========================================================================
; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Sega screen
; ---------------------------------------------------------------------------
	if Revision=0
Nem_SegaLogo:	binclude	"Modes/Cells/SEGA (REV00).nem" ; large Sega logo
		even
Eni_SegaLogo:	binclude	"Modes/Maps/SEGA (REV00).eni" ; large Sega logo (mappings)
		even
	else
Nem_SegaLogo:	binclude	"Modes/Cells/SEGA (REV01).nem" ; large Sega logo
		even
Eni_SegaLogo:	binclude	"Modes/Maps/SEGA (REV01).eni" ; large Sega logo (mappings)
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics and mappings - Title screen
; ---------------------------------------------------------------------------
Eni_Title:	binclude	"Modes/Maps/Title Screen.eni" ; title screen foreground (mappings)
		even
Nem_TitleFg:	binclude	"Modes/Cells/Title Foreground.nem"
		even
Nem_TitleSonic:	binclude	"Modes/Cells/Sonic (Title Screen).nem"
		even
Nem_TitleTM:	binclude	"Modes/Cells/TM.nem"
		even
Eni_JapNames:	binclude	"Modes/Maps/Hidden Japanese Credits.eni" ; Japanese credits (mappings)
		even
Nem_JapNames:	binclude	"Modes/Cells/Hidden Japanese Credits.nem"
		even

; ---------------------------------------------------------------------------
; Uncompressed graphics - Sonic
; ---------------------------------------------------------------------------
Map_Sonic:	include	"Objects/Global/Mappings/Sonic.map"

SonicDynPLC:	include	"Objects/Global/DPLCs/Sonic.dplc"

Art_Sonic:	binclude	"Objects/Global/Cells/Sonic.unc"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
	if Revision=0
Nem_Smoke:	binclude	"Objects/Unused/Cells/Smoke.nem"
		even
Nem_SyzSparkle:	binclude	"Levels/SYZ/Cells/Unused/Sparkles.nem"
		even
	endif

Nem_Shield:	binclude	"Objects/Effects/Cells/Shield.nem"
		even
Nem_Stars:	binclude	"Objects/Effects/Cells/Invincibility Stars.nem"
		even

	if Revision=0
Nem_LzSonic:	binclude	"Levels/LZ/Cells/Unused/Sonic.nem" ; Sonic holding his breath
		even
Nem_UnkFire:	binclude	"Objects/Unused/Cells/Fireball.nem" ; unused fireball
		even
Nem_Warp:	binclude	"Levels/Special/Cells/Unused/Flash.nem" ; entry to special stage flash
		even
Nem_Goggle:	binclude	"Objects/Unused/Cells/Goggles.nem" ; unused goggles
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics - special stage
; ---------------------------------------------------------------------------
Map_SSWalls:	include	"Levels/Special/Mappings/Walls.asm"

Nem_SSWalls:	binclude	"Levels/Special/Cells/Walls.nem" ; special stage walls
		even
Eni_SSBg1:	binclude	"Levels/Special/Maps/Birds and Fish.eni" ; special stage background (mappings)
		even
Nem_SSBgFish:	binclude	"Levels/Special/Cells/Birds and Fish.nem" ; special stage birds and fish background
		even
Eni_SSBg2:	binclude	"Levels/Special/Maps/Clouds and Bubbles.eni" ; special stage background (mappings)
		even
Nem_SSBgCloud:	binclude	"Levels/Special/Cells/Clouds.nem" ; special stage clouds background
		even
Nem_SSGOAL:	binclude	"Levels/Special/Cells/GOAL.nem" ; special stage GOAL block
		even
Nem_SSRBlock:	binclude	"Levels/Special/Cells/R.nem" ; special stage R block
		even
Nem_SS1UpBlock:	binclude	"Levels/Special/Cells/1UP.nem" ; special stage 1UP block
		even
Nem_SSEmStars:	binclude	"Levels/Special/Cells/Emerald Twinkle.nem" ; special stage stars from a collected emerald
		even
Nem_SSRedWhite:	binclude	"Levels/Special/Cells/Red-White.nem" ; special stage red/white block
		even
Nem_SSZone1:	binclude	"Levels/Special/Cells/ZONE1.nem" ; special stage ZONE1 block
		even
Nem_SSZone2:	binclude	"Levels/Special/Cells/ZONE2.nem" ; ZONE2 block
		even
Nem_SSZone3:	binclude	"Levels/Special/Cells/ZONE3.nem" ; ZONE3 block
		even
Nem_SSZone4:	binclude	"Levels/Special/Cells/ZONE4.nem" ; ZONE4 block
		even
Nem_SSZone5:	binclude	"Levels/Special/Cells/ZONE5.nem" ; ZONE5 block
		even
Nem_SSZone6:	binclude	"Levels/Special/Cells/ZONE6.nem" ; ZONE6 block
		even
Nem_SSUpDown:	binclude	"Levels/Special/Cells/UP-DOWN.nem" ; special stage UP/DOWN block
		even
Nem_SSEmerald:	binclude	"Levels/Special/Cells/Emeralds.nem" ; special stage chaos emeralds
		even
Nem_SSGhost:	binclude	"Levels/Special/Cells/Ghost.nem" ; special stage ghost block
		even
Nem_SSWBlock:	binclude	"Levels/Special/Cells/W.nem" ; special stage W block
		even
Nem_SSGlass:	binclude	"Levels/Special/Cells/Glass.nem" ; special stage destroyable glass block
		even
Nem_ResultEm:	binclude	"Levels/Special/Cells/Result Emeralds.nem" ; chaos emeralds on special stage results screen
		even

; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:	binclude	"Levels/GHZ/Cells/Stalk.nem"
		even
Nem_Swing:	binclude	"Objects/Zone/GHZ/Cells/Swinging Platform.nem"
		even
Nem_Bridge:	binclude	"Objects/Zone/GHZ/Cells/Bridge.nem"
		even
Nem_GhzUnkBlock:binclude	"Levels/GHZ/Cells/Unused/Block.nem"
		even
Nem_Ball:	binclude	"Objects/Unused/Cells/GHZ Ball.nem"
		even
Nem_Spikes:	binclude	"Objects/Global/Cells/Spike.nem"
		even
Nem_GhzLog:	binclude	"Levels/GHZ/Cells/Unused/Log.nem"
		even
Nem_SpikePole:	binclude	"Objects/Zone/GHZ/Cells/Spiked Log.nem"
		even
Nem_PplRock:	binclude	"Objects/Zone/GHZ/Cells/Purple Rock.nem"
		even
Nem_GhzWall1:	binclude	"Objects/Zone/GHZ/Cells/Breakable Wall.nem"
		even
Nem_GhzWall2:	binclude	"Objects/Zone/GHZ/Cells/Edge Wall.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_Water:	binclude	"Objects/Zone/LZ/Cells/Water Surface.nem"
		even
Nem_Splash:	binclude	"Objects/Zone/LZ/Cells/Water & Splashes.nem"
		even
Nem_LzSpikeBall:binclude	"Objects/Zone/LZ/Cells/Spiked Ball and Chain.nem"
		even
Nem_FlapDoor:	binclude	"Objects/Zone/LZ/Cells/Flapping Door.nem"
		even
Nem_Bubbles:	binclude	"Objects/Zone/LZ/Cells/Bubbles & Countdown.nem"
		even
Nem_LzBlock3:	binclude	"Objects/Zone/LZ/Cells/32x16 Block.nem"
		even
Nem_LzDoor1:	binclude	"Objects/Zone/LZ/Cells/Vertical Door.nem"
		even
Nem_Harpoon:	binclude	"Objects/Zone/LZ/Cells/Harpoon.nem"
		even
Nem_LzPole:	binclude	"Objects/Zone/LZ/Cells/Breakable Pole.nem"
		even
Nem_LzDoor2:	binclude	"Objects/Zone/LZ/Cells/Horizontal Door.nem"
		even
Nem_LzWheel:	binclude	"Objects/Zone/LZ/Cells/Wheel.nem"
		even
Nem_Gargoyle:	binclude	"Objects/Zone/LZ/Cells/Gargoyle & Fireball.nem"
		even
Nem_LzBlock2:	binclude	"Objects/Zone/LZ/Cells/Blocks.nem"
		even
Nem_LzPlatfm:	binclude	"Levels/LZ/Cells/Rising Platform.nem"
		even
Nem_Cork:	binclude	"Levels/LZ/Cells/Cork.nem"
		even
Nem_LzBlock1:	binclude	"Objects/Zone/LZ/Cells/32x32 Block.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	binclude	"Levels/MZ/Cells/Metal Blocks.nem"
		even
Nem_MzSwitch:	binclude	"Objects/Zone/MZ/Cells/Switch.nem"
		even
Nem_MzGlass:	binclude	"Objects/Zone/MZ/Cells/Green Glass Block.nem"
		even
Nem_UnkGrass:	binclude	"Levels/GHZ/Cells/Unused/Grass.nem"
		even
Nem_MzFire:	binclude	"Objects/Zone/Shared/Cells/Fireballs.nem"
		even
Nem_Lava:	binclude	"Levels/MZ/Cells/Lava.nem"
		even
Nem_MzBlock:	binclude	"Objects/Zone/MZ/Cells/Green Pushable Block.nem"
		even
Nem_MzUnkBlock:	binclude	"Levels/MZ/Cells/Unused/Background.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:	binclude	"Objects/Zone/SLZ/Cells/Seesaw.nem"
		even
Nem_SlzSpike:	binclude	"Levels/SLZ/Cells/Little Spikeball.nem"
		even
Nem_Fan:	binclude	"Objects/Zone/SLZ/Cells/Fan.nem"
		even
Nem_SlzWall:	binclude	"Objects/Zone/SLZ/Cells/Breakable Wall.nem"
		even
Nem_Pylon:	binclude	"Objects/Zone/SLZ/Cells/Pylon.nem"
		even
Nem_SlzSwing:	binclude	"Objects/Zone/SLZ/Cells/Swinging Platform.nem"
		even
Nem_SlzBlock:	binclude	"Levels/SLZ/Cells/32x32 Block.nem"
		even
Nem_SlzCannon:	binclude	"Objects/Zone/SLZ/Cells/Cannon.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:	binclude	"Objects/Zone/SYZ/Cells/Bumper.nem"
		even
Nem_SyzSpike2:	binclude	"Objects/Zone/SYZ/Cells/Small Spikeball.nem"
		even
Nem_LzSwitch:	binclude	"Objects/Zone/Shared/Cells/Switch.nem"
		even
Nem_SyzSpike1:	binclude	"Objects/Zone/SYZ/Cells/Large Spikeball.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - SBZ stuff
; ---------------------------------------------------------------------------
Nem_SbzWheel1:	binclude	"Objects/Zone/SBZ/Cells/Running Disc.nem"
		even
Nem_SbzWheel2:	binclude	"Objects/Zone/SBZ/Cells/Junction Wheel.nem"
		even
Nem_Cutter:	binclude	"Objects/Zone/SBZ/Cells/Pizza Cutter.nem"
		even
Nem_Stomper:	binclude	"Objects/Zone/SBZ/Cells/Stomper.nem"
		even
Nem_SpinPform:	binclude	"Objects/Zone/SBZ/Cells/Spinning Platform.nem"
		even
Nem_TrapDoor:	binclude	"Objects/Zone/SBZ/Cells/Trapdoor.nem"
		even
Nem_SbzFloor:	binclude	"Objects/Zone/SBZ/Cells/Collapsing Floor.nem"
		even
Nem_Electric:	binclude	"Objects/Zone/SBZ/Cells/Electrocuter.nem"
		even
Nem_SbzBlock:	binclude	"Objects/Zone/SBZ/Cells/Vanishing Block.nem"
		even
Nem_FlamePipe:	binclude	"Objects/Zone/SBZ/Cells/Flaming Pipe.nem"
		even
Nem_SbzDoor1:	binclude	"Objects/Zone/SBZ/Cells/Small Vertical Door.nem"
		even
Nem_SlideFloor:	binclude	"Levels/SBZ/Cells/Sliding Floor Trap.nem"
		even
Nem_SbzDoor2:	binclude	"Objects/Zone/SBZ/Cells/Large Horizontal Door.nem"
		even
Nem_Girder:	binclude	"Objects/Zone/SBZ/Cells/Crushing Girder.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	binclude	"Objects/Badniks/Cells/Ball Hog.nem"
		even
Nem_Crabmeat:	binclude	"Objects/Badniks/Cells/Crabmeat.nem"
		even
Nem_Buzz:	binclude	"Objects/Badniks/Cells/Buzz Bomber.nem"
		even
Nem_UnkExplode:	binclude	"Objects/Unused/Cells/Explosion.nem"
		even
Nem_Burrobot:	binclude	"Objects/Badniks/Cells/Burrobot.nem"
		even
Nem_Chopper:	binclude	"Objects/Badniks/Cells/Chopper.nem"
		even
Nem_Jaws:	binclude	"Objects/Badniks/Cells/Jaws.nem"
		even
Nem_Roller:	binclude	"Objects/Badniks/Cells/Roller.nem"
		even
Nem_Motobug:	binclude	"Objects/Badniks/Cells/Motobug.nem"
		even
Nem_Newtron:	binclude	"Objects/Badniks/Cells/Newtron.nem"
		even
Nem_Yadrin:	binclude	"Objects/Badniks/Cells/Yadrin.nem"
		even
Nem_Basaran:	binclude	"Objects/Badniks/Cells/Basaran.nem"
		even
Nem_Splats:	binclude	"Objects/Unused/Cells/Splats.nem"
		even
Nem_Bomb:	binclude	"Objects/Badniks/Cells/Bomb.nem"
		even
Nem_Orbinaut:	binclude	"Objects/Badniks/Cells/Orbinaut.nem"
		even
Nem_Cater:	binclude	"Objects/Badniks/Cells/Caterkiller.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_TitleCard:	binclude	"Objects/Cards/Cells/Title Cards.nem"
		even
Nem_Hud:	binclude	"Objects/Cards/Cells/HUD Text.nem" ; HUD (rings, time, score)
		even
Nem_Lives:	binclude	"Objects/Cards/Cells/Life Icon.nem"
		even
Nem_Ring:	binclude	"Objects/Global/Cells/Ring.nem"
		even
Nem_Monitors:	binclude	"Objects/Global/Cells/Monitor.nem"
		even
Nem_Explode:	binclude	"Objects/Effects/Cells/Explosion.nem"
		even
Nem_Points:	binclude	"Objects/Effects/Cells/Points.nem" ; points from destroyed enemy or object
		even
Nem_GameOver:	binclude	"Objects/Cards/Cells/Game Over.nem" ; game over / time over
		even
Nem_HSpring:	binclude	"Objects/Global/Cells/Spring Horizontal.nem"
		even
Nem_VSpring:	binclude	"Objects/Global/Cells/Spring Vertical.nem"
		even
Nem_SignPost:	binclude	"Objects/Global/Cells/Signpost.nem" ; end of level signpost
		even
Nem_Lamp:	binclude	"Objects/Global/Cells/Lamppost.nem"
		even
Nem_BigFlash:	binclude	"Objects/Global/Cells/Giant Ring Flash.nem"
		even
Nem_Bonus:	binclude	"Objects/Effects/Cells/Hidden Points.nem" ; hidden bonuses at end of a level
		even

; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:	binclude	"Modes/Cells/Sonic (Continue Screen).nem"
		even
Nem_MiniSonic:	binclude	"Modes/Cells/Continue Screen.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Rabbit:	binclude	"Objects/Effects/Cells/Animal Rabbit.nem"
		even
Nem_Chicken:	binclude	"Objects/Effects/Cells/Animal Chicken.nem"
		even
Nem_Penguin:	binclude	"Objects/Effects/Cells/Animal Penguin.nem"
		even
Nem_Seal:	binclude	"Objects/Effects/Cells/Animal Seal.nem"
		even
Nem_Pig:	binclude	"Objects/Effects/Cells/Animal Pig.nem"
		even
Nem_Flicky:	binclude	"Objects/Effects/Cells/Animal Flicky.nem"
		even
Nem_Squirrel:	binclude	"Objects/Effects/Cells/Animal Squirrel.nem"
		even

; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------
Blk16_GHZ:	binclude	"Levels/GHZ/Blocks.eni"
		even
Nem_GHZ_1st:	binclude	"Levels/GHZ/Cells.nem"
		even
Nem_GHZ_2nd:	binclude	"Levels/GHZ/Cells/2nd Cells.nem"
		even
Blk256_GHZ:	binclude	"Levels/GHZ/Chunks.kos"
		even

Blk16_LZ:	binclude	"Levels/LZ/Blocks.eni"
		even
Nem_LZ:		binclude	"Levels/LZ/Cells.nem"
		even
Blk256_LZ:	binclude	"Levels/LZ/Chunks.kos"
		even

Blk16_MZ:	binclude	"Levels/MZ/Blocks.eni"
		even
Nem_MZ:		binclude	"Levels/MZ/Cells.nem"
		even
Blk256_MZ:
	if Revision=0
		binclude	"Levels/MZ/Chunks (REV00).kos"
		even
	else
		binclude	"Levels/MZ/Chunks (REV01).kos"
		even
	endif

Blk16_SLZ:	binclude	"Levels/SLZ/Blocks.eni"
		even
Nem_SLZ:	binclude	"Levels/SLZ/Cells.nem"
		even
Blk256_SLZ:	binclude	"Levels/SLZ/Chunks.kos"
		even

Blk16_SYZ:	binclude	"Levels/SYZ/Blocks.eni"
		even
Nem_SYZ:	binclude	"Levels/SYZ/Cells.nem"
		even
Blk256_SYZ:	binclude	"Levels/SYZ/Chunks.kos"
		even

Blk16_SBZ:	binclude	"Levels/SBZ/Blocks.eni"
		even
Nem_SBZ:	binclude	"Levels/SBZ/Cells.nem"
		even
Blk256_SBZ:
	if Revision=0
		binclude	"Levels/SBZ/Chunks (REV00).kos"
		even
	else
		binclude	"Levels/SBZ/Chunks (REV01).kos"
		even
	endif

; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:	binclude	"Objects/Bosses/Cells/Main.nem"
		even
Nem_Weapons:	binclude	"Objects/Bosses/Cells/Weapons.nem"
		even
Nem_Prison:	binclude	"Objects/Global/Cells/Prison Capsule.nem"
		even
Nem_Sbz2Eggman:	binclude	"Objects/Bosses/Cells/Eggman (SBZ2 & FZ).nem"
		even
Nem_FzBoss:	binclude	"Objects/Bosses/Cells/Egg Crusher.nem"
		even
Nem_FzEggman:	binclude	"Objects/Bosses/Cells/Eggman (After Crusher).nem"
		even
Nem_Exhaust:	binclude	"Objects/Bosses/Cells/Exhaust Flame.nem"
		even
Nem_EndEm:	binclude	"Modes/Cells/End Emeralds.nem"
		even
Nem_EndSonic:	binclude	"Modes/Cells/Sonic (End Cutscene).nem"
		even
Nem_TryAgain:	binclude	"Modes/Cells/Try Again.nem"
		even
	if Revision=0
Nem_EndEggman:
		binclude	"Modes/Cells/Unused/End Eggman.nem"
		even
	endif
Kos_EndFlowers:	binclude	"Levels/GHZ/Cells/End Cutscene Flowers.kos" ; ending sequence animated flowers
		even
Nem_EndFlower:	binclude	"Levels/GHZ/Cells/End Flowers.nem"
		even
Nem_CreditText:	binclude	"Modes/Cells/Credits.nem"
		even
Nem_EndStH:	binclude	"Modes/Cells/STH Logo.nem"
		even

; ---------------------------------------------------------------------------

		; AngleMap starts at $62900 in all revisions, which amounts
		; to $104 bytes of padding for rev00 and $40 for rev01/rev02.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		if Revision=0
			dcb.b	$104,$FF
		else
			dcb.b	$40,$FF
		endif
	endif

; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	binclude	"Levels/Collision/Angle Map.bin"
		even
CollArray1:	binclude	"Levels/Collision/Collision Array (Normal).bin"
		even
CollArray2:	binclude	"Levels/Collision/Collision Array (Rotated).bin"
		even
Col_GHZ:	binclude	"Levels/GHZ/Collision.bin" ; GHZ index
		even
Col_LZ:		binclude	"Levels/LZ/Collision.bin" ; LZ index
		even
Col_MZ:		binclude	"Levels/MZ/Collision.bin" ; MZ index
		even
Col_SLZ:	binclude	"Levels/SLZ/Collision.bin" ; SLZ index
		even
Col_SYZ:	binclude	"Levels/SYZ/Collision.bin" ; SYZ index
		even
Col_SBZ:	binclude	"Levels/SBZ/Collision.bin" ; SBZ index
		even

; ---------------------------------------------------------------------------
; Special Stage layouts
; ---------------------------------------------------------------------------
SS_1:		binclude	"Levels/Special/Layouts/1.eni"
		even
SS_2:		binclude	"Levels/Special/Layouts/2.eni"
		even
SS_3:		binclude	"Levels/Special/Layouts/3.eni"
		even
SS_4:		binclude	"Levels/Special/Layouts/4.eni"
		even
	if Revision=0
SS_5:		binclude	"Levels/Special/Layouts/5 (REV00).eni"
		even
SS_6:		binclude	"Levels/Special/Layouts/6 (REV00).eni"
		even
	else
		; SS 5 and 6 had broken objects outside the accessible Layout;
		; REV01 removes those - remaining Layouts stay unchanged.
SS_5:		binclude	"Levels/Special/Layouts/5 (REV01).eni"
		even
SS_6:		binclude	"Levels/Special/Layouts/6 (REV01).eni"
		even
	endif

; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	binclude	"Levels/GHZ/Cells/Waterfall.unc"
		even
Art_GhzFlower1:	binclude	"Levels/GHZ/Cells/Sunflower.unc"
		even
Art_GhzFlower2:	binclude	"Levels/GHZ/Cells/Small Flower.unc"
		even
Art_MzLava1:	binclude	"Levels/MZ/Cells/Lava Surface.unc"
		even
Art_MzLava2:	binclude	"Levels/MZ/Cells/Lava.unc"
		even
Art_MzTorch:	binclude	"Levels/MZ/Cells/Background Torch.unc"
		even
Art_SbzSmoke:	binclude	"Levels/SBZ/Cells/Background Smoke.unc"
		even

; ---------------------------------------------------------------------------
; Level layout index
; Format: foreground, background, leftover/unused
; ---------------------------------------------------------------------------
Level_Index:
		; GHZ
		dc.w Level_GHZ1-Level_Index, Level_GHZbg-Level_Index, Level_GHZ1Unk-Level_Index
		dc.w Level_GHZ2-Level_Index, Level_GHZbg-Level_Index, Level_GHZ2Unk-Level_Index
		dc.w Level_GHZ3-Level_Index, Level_GHZbg-Level_Index, Level_GHZ3Unk-Level_Index
		dc.w Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index, Level_GHZ4Unk-Level_Index
		; LZ
		dc.w Level_LZ1-Level_Index, Level_LZbg-Level_Index, Level_LZ1Unk-Level_Index
		dc.w Level_LZ2-Level_Index, Level_LZbg-Level_Index, Level_LZ2Unk-Level_Index
		dc.w Level_LZ3-Level_Index, Level_LZbg-Level_Index, Level_LZ3Unk-Level_Index
		dc.w Level_SBZ3-Level_Index, Level_LZbg-Level_Index, Level_SBZ3Unk-Level_Index
		; MZ
		dc.w Level_MZ1-Level_Index, Level_MZ1bg-Level_Index, Level_MZ1-Level_Index
		dc.w Level_MZ2-Level_Index, Level_MZ2bg-Level_Index, Level_MZ2Unk-Level_Index
		dc.w Level_MZ3-Level_Index, Level_MZ3bg-Level_Index, Level_MZ3Unk-Level_Index
		dc.w Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index, Level_MZ4Unk-Level_Index
		; SLZ
		dc.w Level_SLZ1-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ2-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ3-Level_Index, Level_SLZbg-Level_Index, Level_SLZ1Unk-Level_Index
		dc.w Level_SLZ1Unk-Level_Index, Level_SLZ1Unk-Level_Index, Level_SLZ1Unk-Level_Index
		; SYZ
		dc.w Level_SYZ1-Level_Index, Level_SYZbg-Level_Index, Level_SYZ1Unk-Level_Index
		dc.w Level_SYZ2-Level_Index, Level_SYZbg-Level_Index, Level_SYZ2Unk-Level_Index
		dc.w Level_SYZ3-Level_Index, Level_SYZbg-Level_Index, Level_SYZ3Unk-Level_Index
		dc.w Level_SYZ4Unk-Level_Index, Level_SYZ4Unk-Level_Index, Level_SYZ4Unk-Level_Index
		; SBZ
		dc.w Level_SBZ1-Level_Index, Level_SBZ1bg-Level_Index, Level_SBZ1bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, Level_SBZ2bg-Level_Index
		dc.w Level_SBZ2-Level_Index, Level_SBZ2bg-Level_Index, Level_SBZ2Unk-Level_Index
		dc.w Level_SBZ4Unk-Level_Index, Level_SBZ4Unk-Level_Index, Level_SBZ4Unk-Level_Index
		zonewarning Level_Index,24
		; Ending
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_End-Level_Index, Level_GHZbg-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_EndUnk-Level_Index, Level_EndUnk-Level_Index, Level_EndUnk-Level_Index
		dc.w Level_EndUnk-Level_Index, Level_EndUnk-Level_Index, Level_EndUnk-Level_Index

Level_GHZ1:	binclude	"Levels/GHZ/Act 1/Layout.bin"
		even
Level_GHZ1Unk:	dc.l 0
Level_GHZ2:	binclude	"Levels/GHZ/Act 2/Layout.bin"
		even
Level_GHZ2Unk:	dc.l 0
Level_GHZ3:	binclude	"Levels/GHZ/Act 3/Layout.bin"
		even
Level_GHZbg:	binclude	"Levels/GHZ/Background.bin"
		even
Level_GHZ3Unk:	dc.l 0
Level_GHZ4Unk:	dc.l 0

Level_LZ1:	binclude	"Levels/LZ/Act 1/Layout.bin"
		even
Level_LZbg:	binclude	"Levels/LZ/Background.bin"
		even
Level_LZ1Unk:	dc.l 0
Level_LZ2:	binclude	"Levels/LZ/Act 2/Layout.bin"
		even
Level_LZ2Unk:	dc.l 0
Level_LZ3:	binclude	"Levels/LZ/Act 3/Layout.bin"
		even
Level_LZ3Unk:	dc.l 0
Level_SBZ3:	binclude	"Levels/SBZ/Act 3/Layout.bin"
		even
Level_SBZ3Unk:	dc.l 0

Level_MZ1:	binclude	"Levels/MZ/Act 1/Layout.bin"
		even
Level_MZ1bg:	binclude	"Levels/MZ/Act 1/Background.bin"
		even
Level_MZ2:	binclude	"Levels/MZ/Act 2/Layout.bin"
		even
Level_MZ2bg:	binclude	"Levels/MZ/Act 2/Background.bin"
		even
Level_MZ2Unk:	dc.l 0
Level_MZ3:	binclude	"Levels/MZ/Act 3/Layout.bin"
		even
Level_MZ3bg:	binclude	"Levels/MZ/Act 3/Background.bin"
		even
Level_MZ3Unk:	dc.l 0
Level_MZ4Unk:	dc.l 0

Level_SLZ1:	binclude	"Levels/SLZ/Act 1/Layout.bin"
		even
Level_SLZbg:	binclude	"Levels/SLZ/Background.bin"
		even
Level_SLZ2:	binclude	"Levels/SLZ/Act 2/Layout.bin"
		even
Level_SLZ3:	binclude	"Levels/SLZ/Act 3/Layout.bin"
		even
Level_SLZ1Unk:	dc.l 0

Level_SYZ1:	binclude	"Levels/SYZ/Act 1/Layout.bin"
		even
Level_SYZbg:
	if Revision=0
		binclude	"Levels/SYZ/Background (REV00).bin"
	else
		binclude	"Levels/SYZ/Background (REV01).bin"
	endif
		even
Level_SYZ1Unk:	dc.l 0
Level_SYZ2:	binclude	"Levels/SYZ/Act 2/Layout.bin"
		even
Level_SYZ2Unk:	dc.l 0
Level_SYZ3:	binclude	"Levels/SYZ/Act 3/Layout.bin"
		even
Level_SYZ3Unk:	dc.l 0
Level_SYZ4Unk:	dc.l 0

Level_SBZ1:	binclude	"Levels/SBZ/Act 1/Layout.bin"
		even
Level_SBZ1bg:	binclude	"Levels/SBZ/Act 1/Background.bin"
		even
Level_SBZ2:	binclude	"Levels/SBZ/Act 2/Layout.bin"
		even
Level_SBZ2bg:	binclude	"Levels/SBZ/Act 2/Background.bin"
		even
Level_SBZ2Unk:	dc.l 0
Level_SBZ4Unk:	dc.l 0
Level_End:	binclude	"Levels/GHZ/Ending/Layout.bin"
		even
Level_EndUnk:	dc.l 0

; ---------------------------------------------------------------------------
; Uncompressed graphics - Giant Rings
; ---------------------------------------------------------------------------
Art_BigRing:	binclude	"Objects/Global/Cells/Giant Ring.unc"
Art_BigRing_size:	equ	*-Art_BigRing
		even

; ---------------------------------------------------------------------------

		; ObjPos_Index starts at $6B000 in all revisions, which amounts
		; to $9C bytes of padding for rev00 and $DC for rev01/rev02.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		align	$100
	endif

; ---------------------------------------------------------------------------
; Sprite locations index
; ---------------------------------------------------------------------------
ObjPos_Index:
		; GHZ
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_GHZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; LZ
		dc.w ObjPos_LZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_LZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; MZ
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_MZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SLZ
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SLZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SYZ
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ3-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SYZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; SBZ
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ2-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_FZ-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_SBZ1-ObjPos_Index, ObjPos_Null-ObjPos_Index
		zonewarning ObjPos_Index,$10
		; Ending
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		dc.w ObjPos_End-ObjPos_Index, ObjPos_Null-ObjPos_Index
		; --- Put extra object data here. ---
ObjPosLZPlatform_Index:
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
		dc.w ObjPos_LZ2pf1-ObjPos_Index, ObjPos_LZ2pf2-ObjPos_Index
		dc.w ObjPos_LZ3pf1-ObjPos_Index, ObjPos_LZ3pf2-ObjPos_Index
		dc.w ObjPos_LZ1pf1-ObjPos_Index, ObjPos_LZ1pf2-ObjPos_Index
ObjPosSBZPlatform_Index:
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.w ObjPos_SBZ1pf3-ObjPos_Index, ObjPos_SBZ1pf4-ObjPos_Index
		dc.w ObjPos_SBZ1pf5-ObjPos_Index, ObjPos_SBZ1pf6-ObjPos_Index
		dc.w ObjPos_SBZ1pf1-ObjPos_Index, ObjPos_SBZ1pf2-ObjPos_Index
		dc.b $FF, $FF, 0, 0, 0,	0

ObjPos_GHZ1:	binclude	"Levels/GHZ/Act 1/Objects.bin"
		even
ObjPos_GHZ2:	binclude	"Levels/GHZ/Act 2/Objects.bin"
		even
ObjPos_GHZ3:
	if Revision=0
		binclude	"Levels/GHZ/Act 3/Objects (REV00).bin"
		even
	else
		binclude	"Levels/GHZ/Act 3/Objects (REV01).bin"
		even
	endif

ObjPos_LZ1:
	if Revision=0
		binclude	"Levels/LZ/Act 1/Objects (REV00).bin"
		even
	else
		binclude	"Levels/LZ/Act 1/Objects (REV01).bin"
		even
	endif
ObjPos_LZ2:	binclude	"Levels/LZ/Act 2/Objects.bin"
		even
ObjPos_LZ3:
	if Revision=0
		binclude	"Levels/LZ/Act 3/Objects (REV00).bin"
		even
	else
		binclude	"Levels/LZ/Act 3/Objects (REV01).bin"
		even
	endif
ObjPos_SBZ3:	binclude	"Levels/SBZ/Act 3/Objects.bin"
		even

ObjPos_LZ1pf1:	binclude	"Levels/LZ/Act 1/Platforms/1.bin"
		even
ObjPos_LZ1pf2:	binclude	"Levels/LZ/Act 1/Platforms/2.bin"
		even
ObjPos_LZ2pf1:	binclude	"Levels/LZ/Act 2/Platforms/1.bin"
		even
ObjPos_LZ2pf2:	binclude	"Levels/LZ/Act 2/Platforms/2.bin"
		even
ObjPos_LZ3pf1:	binclude	"Levels/LZ/Act 3/Platforms/1.bin"
		even
ObjPos_LZ3pf2:	binclude	"Levels/LZ/Act 3/Platforms/2.bin"
		even

ObjPos_MZ1:
	if Revision=0
		binclude	"Levels/MZ/Act 1/Objects (REV00).bin"
		even
	else
		binclude	"Levels/MZ/Act 1/Objects (REV01).bin"
		even
	endif
ObjPos_MZ2:	binclude	"Levels/MZ/Act 2/Objects.bin"
		even
ObjPos_MZ3:	binclude	"Levels/MZ/Act 3/Objects.bin"
		even

ObjPos_SLZ1:	binclude	"Levels/SLZ/Act 1/Objects.bin"
		even
ObjPos_SLZ2:	binclude	"Levels/SLZ/Act 2/Objects.bin"
		even
ObjPos_SLZ3:	binclude	"Levels/SLZ/Act 3/Objects.bin"
		even
ObjPos_SYZ1:	binclude	"Levels/SYZ/Act 1/Objects.bin"
		even
ObjPos_SYZ2:	binclude	"Levels/SYZ/Act 2/Objects.bin"
		even
ObjPos_SYZ3:
	if Revision=0
		binclude	"Levels/SYZ/Act 3/Objects (REV00).bin"
		even
	else
		binclude	"Levels/SYZ/Act 3/Objects (REV01).bin"
		even
	endif

ObjPos_SBZ1:
	if Revision=0
		binclude	"Levels/SBZ/Act 1/Objects (REV00).bin"
		even
	else
		binclude	"Levels/SBZ/Act 1/Objects (REV01).bin"
		even
	endif
ObjPos_SBZ2:	binclude	"Levels/SBZ/Act 2/Objects.bin"
		even
ObjPos_FZ:	binclude	"Levels/SBZ/Final/Objects.bin"
		even

ObjPos_SBZ1pf1:	binclude	"Levels/SBZ/Act 1/Platforms/1.bin"
		even
ObjPos_SBZ1pf2:	binclude	"Levels/SBZ/Act 1/Platforms/2.bin"
		even
ObjPos_SBZ1pf3:	binclude	"Levels/SBZ/Act 1/Platforms/3.bin"
		even
ObjPos_SBZ1pf4:	binclude	"Levels/SBZ/Act 1/Platforms/4.bin"
		even
ObjPos_SBZ1pf5:	binclude	"Levels/SBZ/Act 1/Platforms/5.bin"
		even
ObjPos_SBZ1pf6:	binclude	"Levels/SBZ/Act 1/Platforms/6.bin"
		even

ObjPos_End:	binclude	"Levels/GHZ/Ending/Objects.bin"
		even

ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0

; ---------------------------------------------------------------------------

		; SoundDriver starts at $71990 in all revisions, which amounts
		; to $62A bytes of padding for rev00 and $63C for rev01/rev02.
		; It appears to be placed in such a way that the sound driver
		; ends right on the $80000 mark in the ROM in all revisions.
		; From a technical standpoint, this padding serves no purpose.
	if PaddingOptimization=0
		if Revision=0
			dcb.b	$62A,$FF
		else
			dcb.b	$63C,$FF
		endif
	endif

; ---------------------------------------------------------------------------

SoundDriver:	include "Sound/Driver.asm"
		even

; ---------------------------------------------------------------------------

; end of 'ROM'
EndOfRom:

		END
