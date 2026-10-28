; ---------------------------------------------------------------------------
; Title screen
; ---------------------------------------------------------------------------

; TitleScreen:
GM_Title:		; fading out from previous game mode
		move.b	#bgm_Stop,d0				; set stop music command
		bsr.w	QueueSound2				; stop music
		bsr.w	ClearPLC				; stop any potential in-progress PLC
		bsr.w	PaletteFadeOut				; fade-out previous game mode
; ---------------------------------------------------------------------------

		; screen setup and loading "SONIC TEAM PRESENTS" (STP) patterns
		disable_ints					; disable ints while accessing the VDP
		bsr.w	DACDriverLoad				; load Z80 driver
		lea	(vdp_control_port).l,a6			; load VDP control port
		move.w	#vreg_mode1|%000100,(a6)		; use 8-colour mode
		move.w	#vreg_fgvram|(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#vreg_bgvram|(vram_bg>>13),(a6)		; set background nametable address
		move.w	#vreg_planesize|%000001,(a6)		; 64-cell hscroll size
		move.w	#vreg_winypos|0,(a6)			; window vertical position
		move.w	#vreg_mode3|%0011,(a6)			; line scroll mode (per-row horizontally, full-screen vertically)
		move.w	#vreg_bgcolor|2<<4|0,(a6)		; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w				; clear water state
		bsr.w	ClearScreen				; wipe the screen
		clearRAM v_objspace				; clear object RAM

		locVRAM	ArtTile_Title_Japanese_Text*tile_size	; set target VRAM location for hidden Japanese credits
		lea	(Nem_JapNames).l,a0			; load hidden Japanese credits
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		locVRAM	ArtTile_Sonic_Team_Font*tile_size	; set target VRAM location for "SONIC TEAM PRESENTS" font
		lea	(Nem_CreditText).l,a0			; load STP font (same as the credits font)
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer
		lea	(Eni_JapNames).l,a0			; load mappings for hidden Japanese credits
	if FixBugs
		move.w	#ArtTile_Title_Japanese_Text|Tile_Pal3,d0 ; set art tile for hidden Japanese credits (cyan)
	else
		; The hidden Japanese credits cheat in Object 8A sets the text color to cyan on palette line 3,
		; but this part makes the text continue using palette line 1, rendering them black instead.
		move.w	#ArtTile_Title_Japanese_Text|Tile_Pal1,d0 ; set art tile for hidden Japanese credits (black)
	endif
		bsr.w	EniDec					; decompress Enigma-compressed mappings to RAM buffer
		copyTilemap v_ram_start,vram_fg,40,28		; transfer decompressed patterns from RAM buffer to VRAM

		clearRAM v_palette_fading			; set palette fade-in buffer to all-black
		moveq	#palid_Sonic,d0				; load Sonic's palette...
		bsr.w	PalLoad_Fade				; ...into fade-in buffer
		move.b	#id_CreditsText,(v_sonicteam).w		; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l			; execute objects to load STP object
		jsr	(BuildSprites).l			; build sprites for the STP object
		bsr.w	PaletteFadeIn				; fade-in STP screen
; ---------------------------------------------------------------------------

		; load main title screen patterns while "SONIC TEAM PRESENTS" screen is shown
		disable_ints					; display is frozen during the STP screen

		locVRAM	ArtTile_Title_Foreground*tile_size	; set target VRAM location title screen foreground emblem
		lea	(Nem_TitleFg).l,a0			; load title screen foreground emblem patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		locVRAM	ArtTile_Title_Sonic*tile_size		; set target VRAM location big Sonic object
		lea	(Nem_TitleSonic).l,a0			; load big Sonic title screen patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		locVRAM	ArtTile_Title_Trademark*tile_size	; set target VRAM location for "TM" patterns
		lea	(Nem_TitleTM).l,a0			; load "TM" patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		lea	(vdp_data_port).l,a6			; load VDP data transfer port
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6) ; set target VRAM location for level select font
		lea	(Art_Text).l,a5				; load uncompressed level select font
		move.w	#(Art_Text_end-Art_Text)/2-1,d1		; set loop count for level select
Tit_LoadText:
		move.w	(a5)+,(a6)				; write one row of the level select font to VRAM
		dbf	d1,Tit_LoadText				; loop until it's fully loaded

		move.b	#0,(v_lastlamp).w			; clear lamppost counter
		move.w	#0,(v_debuguse).w			; exit debug mode if necessary
		move.w	#0,(f_demo).w				; disable demo mode
		move.w	#0,(v_unused2).w			; unused variable
		move.w	#id_GHZ_act1,(v_zone_act).w		; set level to GHZ1 (000)
		move.w	#0,(v_pcyc_time).w			; disable palette cycling
		bsr.w	LevelSizeLoad				; load level size (will use GHZ1's sizes)
		bsr.w	DeformLayers				; initialize background deformation before fade-in (redundant here)

		lea	(v_16x16).w,a1				; set target buffer for blocks mappings
		lea	(Blk16_GHZ).l,a0			; load GHZ 16x16 blocks mappings
		move.w	#ArtTile_Level,d0			; set to target VRAM address $0000
		bsr.w	EniDec					; decompress Enigma-compressed blocks mappings to buffer

		lea	(Blk256_GHZ).l,a0			; load GHZ 256x256 mappings
		lea	(v_256x256).l,a1			; set target buffer for chunks mappings
		bsr.w	KosDec					; decompress Kosinski-compressed chunks mappings to buffer

		bsr.w	LevelLayoutLoad				; load level layout for the background
		bsr.w	PaletteFadeOut				; fade-out "SONIC TEAM PRESENTS" screen
; ---------------------------------------------------------------------------

		; "SONIC TEAM PRESENTS" screen has faded out, load remaining patterns and fade in
		disable_ints					; disable interrupts again after the fade-out
		bsr.w	ClearScreen				; wipe screen

		lea	(vdp_control_port).l,a5			; set VDP control port
		lea	(vdp_data_port).l,a6			; set VDP data port
		lea	(v_bgscreenposx).w,a3			; get current background X position
		lea	(v_lvllayout_bg).w,a4			; get location in level layout RAM where background is stored
		move.w	#$4000+(vram_bg-vram_fg),d2		; =$6000 (VRAM write command $4000 + nametable start address relative to vram_fg)
		bsr.w	DrawChunks				; draw initial background layer

		lea	(v_ram_start).l,a1			; set start of RAM to be used as decompression buffer (this overwrites unused chunk RAM)
		lea	(Eni_Title).l,a0			; load title screen emblem mappings
		move.w	#ArtTile_Level,d0			; =$0000 (emblem mappings are themselves set up with a +$2000 offset per tile)
		bsr.w	EniDec					; decompress Enigma-compressed emblem mappings to buffer
	if FixBugs
		; Fix title screen position
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Title_Screen_position_in_Sonic_1
		copyTilemap v_ram_start,vram_fg+$208,34,22	; transfer decompressed patterns from RAM buffer to VRAM (correctly centered)
	else
		copyTilemap v_ram_start,vram_fg+$206,34,22	; transfer decompressed patterns from RAM buffer to VRAM (off-center)
	endif

		locVRAM	ArtTile_Level*tile_size			; set target VRAM location for level patterns
		lea	(Nem_GHZ_1st).l,a0			; load first half of GHZ patterns
		bsr.w	NemDec					; decompress Nemesis-compressed patterns directly to VRAM

		moveq	#palid_Title,d0				; load title screen palette...
		bsr.w	PalLoad_Fade				; ...to fade-in buffer
		move.b	#bgm_Title,d0				; set title screen music
		bsr.w	QueueSound2				; play title screen music
		move.b	#0,(f_debugmode).w			; disable debug mode (cheat remains active though)
		move.w	#376,(v_generictimer).w			; run title screen for 376 frames (6 seconds plus some change)

	if FixBugs
		; Fix the Press Start Button text
		; https://info.sonicretro.org/SCHG_How-to:Display_the_Press_Start_Button_text
		clearRAM v_sonicteam,v_sonicteam+object_size	; delete RAM used by "SONIC TEAM PRESENTS" object (fully)
	else
		; Bug: this only clears half of the "SONIC TEAM PRESENTS" slot.
		; This is responsible for why the "PRESS START BUTTON" text doesn't
		; show up, as the routine ID isn't reset.
		clearRAM v_sonicteam,v_sonicteam+object_size/2	; delete RAM used by "SONIC TEAM PRESENTS" object (partially)
	endif

		move.b	#id_TitleSonic,(v_titlesonic).w		; load big Sonic object
		move.b	#id_PSBTM,(v_pressstart).w		; load "PRESS START BUTTON" object
	;	clr.b	(v_pressstart+obRoutine).w		; The 'Mega Games 10' version of Sonic 1 added this line to fix the 'PRESS START BUTTON' object not appearing

	if Revision<>0
		tst.b	(v_megadrive).w				; is console Japanese?
		bpl.s	.isjap					; if yes, don't load TM object
	endif
		move.b	#id_PSBTM,(v_titletm).w			; load title screen HUD object
		move.b	#3,(v_titletm+obFrame).w		; set it to the "TM" frame
	.isjap:

		move.b	#id_PSBTM,(v_ttlsonichide).w		; load title screen HUD object
		move.b	#2,(v_ttlsonichide+obFrame).w		; load object which hides part of Sonic's torso behind the emblem

		jsr	(ExecuteObjects).l			; load title screen objects
		bsr.w	DeformLayers				; initialize background deformation before fade-in
		jsr	(BuildSprites).l			; build sprites for the title screen objects before fade-in
		moveq	#plcid_Main,d0				; load main patterns (rings, etc.)
		bsr.w	NewPLC					; (these get loaded once for the title screen and then never again, except when exiting Special Stages)

		move.w	#0,(v_title_dcount).w			; clear D-Pad counter for title screen cheats
		move.w	#0,(v_title_ccount).w			; clear C counter for title screen cheats
; ---------------------------------------------------------------------------

		; fade-in palette and enter main loop
		enable_display					; enable display
		bsr.w	PaletteFadeIn				; fade-in title screen

; ---------------------------------------------------------------------------
; Title screen main loop and cheat checks
; ---------------------------------------------------------------------------

Tit_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		jsr	(ExecuteObjects).l			; execute title screen objects
		bsr.w	DeformLayers				; run background deformation
		jsr	(BuildSprites).l			; display sprites
		bsr.w	PalCycle_Title				; run title screen palette cycle
		bsr.w	RunPLC					; run any potential PLC

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_ChkRegion				; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

Tit_ChkRegion:
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_RegionJap				; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; load US code
		bra.s	Tit_EnterCheat				; skip over

Tit_RegionJap:
		lea	(LevSelCode_J).l,a0			; load J code

Tit_EnterCheat:
		move.w	(v_title_dcount).w,d0			; get number of successful D-Pad cheat inputs
		adda.w	d0,a0					; add to loaded code to find current cheat input requirement
		move.b	(v_jpadpress1).w,d0			; get buttons pressed this frame
		andi.b	#btnDir,d0				; read only D-Pad buttons (UDLR)
		cmp.b	(a0),d0					; does button press match current cheat entry?
		bne.s	Tit_ResetCheat				; if not, branch and reset cheat
		addq.w	#1,(v_title_dcount).w			; increment number of successful D-Pad cheat inputs
		tst.b	d0					; has end of cheat code been reached? (0-entry in cheat)
		bne.s	Tit_CountC				; if not, branch
	if FixBugs
		; Allow additional cheats to be entered without resetting the sequence first.
		clr.w	(v_title_dcount).w			; reset D-Pad counter
	endif

Tit_ActivateCheat:
		; (On JAPANESE consoles only) Activated cheat depends on the amount of times C was pressed:
		; 0-1 level select -- 2-3 slow motion -- 4-5 debug mode -- 6-7: hidden Japanese credits & sound test 9E/9F
		; For any other regions, pressing C twice or more will ALWAYS result in slow motion and debug mode,
		; and the hidden Japanese credits cheat is unavailable under any circumstances on such consoles.
		lea	(f_levselcheat).w,a0			; get base cheat index
		move.w	(v_title_ccount).w,d1			; get number of tiles C was pressed
		lsr.w	#1,d1					; half pressed amount
		andi.w	#3,d1					; only four cheats are possible
		beq.s	Tit_PlayRing				; if C was not pressed, only activate level select
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	Tit_PlayRing				; if Japanese, branch
		moveq	#1,d1					; on non-Japanese console, force index to slow motion cheat
		move.b	d1,1(a0,d1.w)				; enable debug mode first (and slow motion in the next line)

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat depending on C-press count
		move.b	#sfx_Ring,d0				; set ring sound when code is entered
		bsr.w	QueueSound2				; play it
		bra.s	Tit_CountC				; skip over cheat reset
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0					; has D-Pad been pressed?
		beq.s	Tit_CountC				; if not, don't reset D-Pad counter
		cmpi.w	#9,(v_title_dcount).w			; has cheat reached index 9? (impossible condition)
		beq.s	Tit_CountC				; if yes, don't reset D-Pad counter
		move.w	#0,(v_title_dcount).w			; reset cheat index counter
	if FixBugs
		; Entering an incorrect cheat input normally resets the entire sequence.
		; If the incorrect input matches the first cheat button, it should be treated
		; as the first successful input to make repeated attempts less awkward.
		lea	(LevSelCode_J).l,a0			; reload J code
		tst.b	(v_megadrive).w				; check if the machine is US or Japanese
		bpl.s	.chkUp					; if Japanese, branch
		lea	(LevSelCode_US).l,a0			; reload US code
	.chkUp:	cmp.b	(a0),d0					; was incorrect button press the first cheat input?
		beq.s	Tit_EnterCheat				; if yes, treat it as first correct input right away
	endif

Tit_CountC:
		move.b	(v_jpadpress1).w,d0			; get currently pressed buttons
		andi.b	#btnC,d0				; is C button pressed?
		beq.s	Tit_ChkStartOrDemo			; if not, branch
		addq.w	#1,(v_title_ccount).w			; increment C counter

; loc_3230:
Tit_ChkStartOrDemo:
		tst.w	(v_generictimer).w			; has title screen timer expired?
		beq.w	GotoDemo				; if yes, launch Demo mode
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, continue looping title screen

Tit_ChkLevSel:
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, begin game by playing normal level
		btst	#bitA,(v_jpadhold1).w			; check if A was held while pressing Start
		beq.w	PlayLevel				; if not, begin game by playing normal level
; ---------------------------------------------------------------------------

Tit_EnterLevelSelect:
	if FixBugs
		; Fix the level selects graphics bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Level_Select_graphics_bug
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; run VBlank one extra frame to prevent graphical glitches
	endif
		moveq	#palid_LevelSel,d0			; load level select palette...
		bsr.w	PalLoad					; ...directly to active palette

		clearRAM v_hscrolltablebuffer			; clear H-Scroll buffer
		move.l	d0,(v_scrposy_vdp).w			; clear VSRAM (d0 is still 0)
		disable_ints					; disable interrupts

		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	vram_bg					; write to background nametable
		move.w	#plane_size_64x32/4-1,d1		; write full screen
.LevSelClearBG:	move.l	d0,(a6)					; clear background plane
		dbf	d1,.LevSelClearBG			; loop until plane is fully cleared

		bsr.w	LevSelTextLoad				; load level select text before entering main loop

; ---------------------------------------------------------------------------
; Level Select main loop
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	LevSelControls				; update selected line if necessary
		bsr.w	RunPLC					; run any potential PLC
		tst.l	(v_plc_buffer).w			; are any patterns in the PLC still left to be loaded?
		bne.s	LevelSelect				; if yes, block quitting level select until finished
		andi.b	#btnABC+btnStart,(v_jpadpress1).w	; is A, B, C, or Start pressed?
		beq.s	LevelSelect				; if not, loop level select

LevSel_SelectionMade:
		move.w	(v_levselitem).w,d0			; get currently selected line
		cmpi.w	#levsel_sndtest_row,d0			; have you selected item $14 (sound test)?
		bne.s	LevSel_Level_SS				; if not, go to Level/SS subroutine
		move.w	(v_levselsound).w,d0			; get currently selected sound test entry
		addi.w	#$80,d0					; make it $80-based

		; 9E/9F shortcuts with hidden Japanese Credits cheat
		tst.b	(f_creditscheat).w			; is hidden Japanese Credits cheat on?
		beq.s	LevSel_NoCheat				; if not, branch
		cmpi.w	#$9F,d0					; is sound $9F being played?
		beq.s	LevSel_Ending				; if yes, go to Ending Sequence
		cmpi.w	#$9E,d0					; is sound $9E being played?
		beq.s	LevSel_Credits				; if yes, go to Credits
LevSel_NoCheat:
	if FixBugs=0
		; This is a workaround for a bug (see PlaySoundID in the sound driver for more info)
		cmpi.w	#bgm__Last+1,d0				; is sound $80-$93 being played?
		blo.s	LevSel_PlaySnd				; if yes, branch
		cmpi.w	#sfx__First,d0				; is sound $94-$9F being played?
		blo.s	LevelSelect				; if yes, branch
LevSel_PlaySnd:
	endif
		bsr.w	QueueSound2				; play selected sound
		bra.s	LevelSelect				; loop level select
; ===========================================================================

LevSel_Ending:
		move.b	#id_Ending,(v_gamemode).w 		; set screen mode to $18 (Ending)
		move.w	#id_EndZ_good,(v_zone_act).w  		; set level to good Ending (will be bad Ending without 6 emeralds)
		rts
; ===========================================================================

LevSel_Credits:
		move.b	#id_Credits,(v_gamemode).w		; set screen mode to $1C (Credits)
		move.b	#bgm_Credits,d0				; set credits music
		bsr.w	QueueSound2				; play it
		move.w	#0,(v_creditsnum).w			; start at the first credits page
		rts
; ===========================================================================

LevSel_Level_SS:
		add.w	d0,d0					; double selected line for word-based indexing
		move.w	LevSel_Ptrs(pc,d0.w),d0			; find relevant level pointer from table
		bmi.w	LevelSelect				; if it's an invalid entry, branch back to main loop
		cmpi.w	#id_SS<<8,d0				; check if selected level Special Stage (0700 is used as dummy value)
		bne.s	LevSel_Level				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set screen mode to $10 (Special Stage)
		clr.w	(v_zone_act).w				; clear level
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
	if Revision<>0
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
	endif
		rts
; ===========================================================================

LevSel_Level:
		andi.w	#$3FFF,d0				; mask out invalid bits of level number
		move.w	d0,(v_zone_act).w			; set new level number (zone and act)

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; set d0 to 0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastspecial).w			; clear special stage number
		move.b	d0,(v_emeralds).w			; clear emeralds
		move.l	d0,(v_emldlist).w			; clear emeralds
		move.l	d0,(v_emldlist+4).w			; clear emeralds
		move.b	d0,(v_continues).w			; clear continues
	if Revision<>0
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
	endif
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music
		rts						; return to MainGameLoop to start level
; End of function GM_Title

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select - level pointers
; ---------------------------------------------------------------------------
; This is just for the pointers. For the text itself, see: LevelMenuText
; ---------------------------------------------------------------------------

LevSel_Ptrs:
		dc.w id_GHZ_act1
		dc.w id_GHZ_act2
		dc.w id_GHZ_act3
	if Revision=0
		; old level order
		dc.w id_LZ_act1
		dc.w id_LZ_act2
		dc.w id_LZ_act3
		dc.w id_MZ_act1
		dc.w id_MZ_act2
		dc.w id_MZ_act3
		dc.w id_SLZ_act1
		dc.w id_SLZ_act2
		dc.w id_SLZ_act3
		dc.w id_SYZ_act1
		dc.w id_SYZ_act2
		dc.w id_SYZ_act3
	else
		; correct level order
		dc.w id_MZ_act1
		dc.w id_MZ_act2
		dc.w id_MZ_act3
		dc.w id_SYZ_act1
		dc.w id_SYZ_act2
		dc.w id_SYZ_act3
		dc.w id_LZ_act1
		dc.w id_LZ_act2
		dc.w id_LZ_act3
		dc.w id_SLZ_act1
		dc.w id_SLZ_act2
		dc.w id_SLZ_act3
	endif
		dc.w id_SBZ_act1
		dc.w id_SBZ_act2
		dc.w id_LZ_act4			; Scrap Brain Zone 3
		dc.w id_FZ			; Final Zone
		dc.w id_SS<<8			; Special Stage (dummy value)
		dc.w $8000			; Sound Test
LevSel_PtrsEnd:	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select codes
; ---------------------------------------------------------------------------

LevSelCode_J:
	if Revision=0
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
	else
		dc.b btnUp,btnDn,btnDn,btnDn,btnL,btnR,0,$FF
	endif
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo mode loading routine
; ---------------------------------------------------------------------------

GotoDemo:	; wait half a second on the final frame of Sonic's finger wagging before going to demo
		move.w	#30,(v_generictimer).w			; set timeout to 30 frames

; loc_33B6:
GotoDemo_PreDelayLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w	; set VBlank routine to $04
		bsr.w	WaitForVBlank				; wait for VBlank to finish
		bsr.w	DeformLayers				; run background deformation
		bsr.w	PaletteCycle				; run normal palette cycle routine (this briefly uses GHZ's cycle)
		bsr.w	RunPLC					; run any potential PLC

		move.w	(v_player+obX).w,d0			; get current title screen position (big Sonic object)
		addq.w	#2,d0					; move it 2px to the right
		move.w	d0,(v_player+obX).w			; write new X position
		cmpi.w	#$1C00,d0				; has Sonic object passed $1C00 on x-axis?
		blo.s	GotoDemo_ChkLoop			; if not, branch
		; Will never happen due to the short title screen generic timer.
		; This likely was an old failsafe before Demos were introduced.
		move.b	#id_Sega,(v_gamemode).w			; return to Sega screen
		rts
; ===========================================================================

; loc_33E4:
GotoDemo_ChkLoop:
		andi.b	#btnStart,(v_jpadpress1).w		; has Start button been pressed during pre-delay?
		bne.w	Tit_ChkLevSel				; if yes, abort loading demo and load normal level instead
		tst.w	(v_generictimer).w			; has pre-delay timer expired?
		bne.w	GotoDemo_PreDelayLoop			; if not, branch
; ---------------------------------------------------------------------------

		; start loading demo now
		move.b	#bgm_Fade,d0				; set music fade-out command
		bsr.w	QueueSound2				; fade out music

		move.w	(v_demonum).w,d0			; load demo number
		andi.w	#7,d0					; limit to four demo entries
		add.w	d0,d0					; double for word-based indexing
		move.w	Demo_Levels(pc,d0.w),d0			; load level number for demo
		move.w	d0,(v_zone_act).w			; set level for demo

		addq.w	#1,(v_demonum).w			; add 1 to demo number
		cmpi.w	#4,(v_demonum).w			; is demo number less than 4?
		blo.s	GotoDemo_NoReset			; if yes, branch
		move.w	#0,(v_demonum).w			; reset demo number to 0

; loc_3422:
GotoDemo_NoReset:
		move.w	#1,(f_demo).w				; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set game mode to 08 (demo)

		cmpi.w	#$600,d0				; is level number 0600 (Special Stage dummy value)?
		bne.s	GotoDemo_NotSS				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set game mode to $10 (Special Stage)
		clr.w	(v_zone_act).w				; clear level number
		clr.b	(v_lastspecial).w			; clear special stage number to play demo in stage 1

; Demo_Level:
GotoDemo_NotSS:
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0					; clear d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
	if Revision<>0
		move.l	#5000,(v_scorelife).w			; extra life is awarded at 50000 points
	endif
		rts						; return to MainGameLoop to start demo
; End of function GotoDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------

Demo_Levels:	; previously in "misc/Demo Level Order - Intro.bin"
		dc.w id_GHZ_act1
		dc.w id_MZ_act1
		dc.w id_SYZ_act1
		dc.w $600 ; used as dummy value to start the Special Stage demo
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to change what you're selecting in the level select
; ---------------------------------------------------------------------------

LevSelControls:
		move.b	(v_jpadpress1).w,d1			; get current button presses
		andi.b	#btnUp+btnDn,d1				; is up/down pressed this frame?
		bne.s	LevSel_UpDown				; if yes, branch
		subq.w	#1,(v_levseldelay).w			; if held, subtract 1 from delay until next move
		bpl.s	LevSel_SndTest				; if time remains, branch

LevSel_UpDown:
		move.w	#12-1,(v_levseldelay).w			; reset time delay
		move.b	(v_jpadhold1).w,d1			; get currently held buttons
		andi.b	#btnUp+btnDn,d1				; is up/down held?
		beq.s	LevSel_SndTest				; if not, branch
		move.w	(v_levselitem).w,d0			; get currently selected line
		btst	#bitUp,d1				; is up held?
		beq.s	LevSel_Down				; if not, branch
		subq.w	#1,d0					; move up 1 selection
		bhs.s	LevSel_Down				; if entry is still valid, branch
		moveq	#levsel_line_count-1,d0			; if selection moves below 0, jump to selection last row

LevSel_Down:
		btst	#bitDn,d1				; is down held?
		beq.s	LevSel_Refresh				; if not, branch
		addq.w	#1,d0					; move down 1 selection
		cmpi.w	#levsel_line_count,d0			; is selection past the last one now?
		blo.s	LevSel_Refresh				; if not, branch
		moveq	#0,d0					; if selection moves past the last row, jump to selection 0

LevSel_Refresh:
		move.w	d0,(v_levselitem).w			; set new selection
		bsr.w	LevSelTextLoad				; refresh text
		rts
; ===========================================================================

LevSel_SndTest:
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is sound test row selected?
		bne.s	LevSel_NoMove				; if not, branch
		move.b	(v_jpadpress1).w,d1			; get currently pressed buttons
		andi.b	#btnR+btnL,d1				; is left/right pressed?
		beq.s	LevSel_NoMove				; if not, branch

		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		btst	#bitL,d1				; is left pressed?
		beq.s	LevSel_Right				; if not, branch
		subq.w	#1,d0					; subtract 1 from sound test
		bhs.s	LevSel_Right				; is result still positive? if yes, branch
		moveq	#sfx__Last-$80,d0 			; if sound test moves below 0, set to last entry (non-$80 based)

LevSel_Right:
		btst	#bitR,d1				; is right pressed?
		beq.s	LevSel_Refresh2				; if not, branch
		addq.w	#1,d0					; add 1 to sound test
		cmpi.w	#sfx__Last-$80+1,d0			; is result now past the last entry?
		blo.s	LevSel_Refresh2				; if not, branch
		moveq	#0,d0					; if sound test moves above last entry, set to 0

LevSel_Refresh2:
		move.w	d0,(v_levselsound).w			; set sound test number
		bsr.w	LevSelTextLoad				; refresh text

LevSel_NoMove:
		rts
; End of function LevSelControls

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

levsel_line_count:	equ 21	; total number of lines
levsel_line_length:	equ 24	; characters per line
levsel_sndtest_row:	equ levsel_line_count-1  ; row index of the sound test
levsel_sndtest_col:	equ levsel_line_length-8 ; column offset for the sound test number

levsel_start_row:	equ 4	; top tile offset for start position
levsel_start_col:	equ 8	; left tile offset for start position
levsel_vram_main:	equ vram_bg+(levsel_start_row<<7)+(levsel_start_col<<1)	; nametable address in VRAM
levsel_vram_sndtestnum:	equ levsel_vram_main+(levsel_sndtest_row<<7)+(levsel_sndtest_col<<1) ; nametable address for sound test numbers

levsel_white:		equ ArtTile_Level_Select_Font|Tile_Pal4|Tile_Prio ; VRAM setting for white text (non-selected lines)
levsel_yellow:		equ ArtTile_Level_Select_Font|Tile_Pal3|Tile_Prio ; VRAM setting for yellow text (selected line)

; ---------------------------------------------------------------------------

LevSelTextLoad:
		; Write main text in white
		lea	(LevelMenuText).l,a1			; load menu text offset
		lea	(vdp_data_port).l,a6			; prepare VDP data write
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		move.w	#levsel_white,d3			; VRAM setting
		moveq	#levsel_line_count-1,d1			; number of lines of text to write
.DrawAll:	move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; draw line of text
		addi.l	#$00800000,d4				; jump to next line
		dbf	d1,.DrawAll				; repeat until all lines are drawn

		; Draw currently selected line in yellow
		moveq	#0,d0					; clear d0
		move.w	(v_levselitem).w,d0			; get currently selected line
		move.w	d0,d1					; back up selected line
		locVRAM	levsel_vram_main,d4			; prepare base VRAM nametable location in d4
		lsl.w	#7,d0					; times $80
		swap	d0					; swap so that line now becomes VRAM nametable offset
		add.l	d0,d4					; add that to base VRAM location
		lea	(LevelMenuText).l,a1			; load menu text offset
	if levsel_line_length=24
		lsl.w	#3,d1					; times 8
		move.w	d1,d0					; copy result
		add.w	d1,d1					; times...
		add.w	d0,d1					; ...3 (because default line length 8 x 3 = 24)
	else
		; The above calculation assumes 24 as line length, we need a different approach if it changes.
		mulu.w	#levsel_line_length,d1			; multiply selected line index by line length
	endif
		adda.w	d1,a1					; add to menu text offset
		move.w	#levsel_yellow,d3 			; prepare selected-line VRAM setting
		move.l	d4,4(a6)				; write to VDP
		bsr.w	LevSel_ChgLine				; recolour selected line

		; Write sound test numbers
		move.w	#levsel_white,d3			; draw numbers in white by default
		cmpi.w	#levsel_sndtest_row,(v_levselitem).w	; is currently selected line the sound test?
		bne.s	LevSel_DrawSnd				; if not, branch
		move.w	#levsel_yellow,d3			; draw numbers in yellow
LevSel_DrawSnd:
		locVRAM	levsel_vram_sndtestnum			; write sound test number position to VRAM
		move.w	(v_levselsound).w,d0			; get currently selected sound test number
		addi.w	#$80,d0					; make sound ID to be drawn $80-based
		move.b	d0,d2					; backup number
		lsr.b	#4,d0					; move first digit to lower nybble
		bsr.w	LevSel_ChgSnd				; draw 1st digit
		move.b	d2,d0					; restore backup
		bsr.w	LevSel_ChgSnd				; draw 2nd digit
		rts
; ===========================================================================

LevSel_ChgSnd:
		andi.w	#$F,d0					; mask out upper nybble
		cmpi.b	#$A,d0					; is digit $A-$F?
		blo.s	.DrawNum				; if not, branch
		addi.b	#7,d0					; use letter characters
.DrawNum:	add.w	d3,d0					; combine number with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		rts
; ===========================================================================

LevSel_ChgLine:
		moveq	#levsel_line_length-1,d2		; number of characters per line

.LineLoop:	moveq	#0,d0					; clear d0
		move.b	(a1)+,d0				; get current character
		bpl.s	.CharOk					; is it a valid ASCII character? if yes, branch
		move.w	#0,(a6)					; draw a blank character
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts

.CharOk:	add.w	d3,d0					; combine char with VRAM setting (white or yellow)
		move.w	d0,(a6)					; send to VRAM
		dbf	d2,.LineLoop				; loop until all characters are drawn
		rts
; End of function LevSelTextLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level select menu text
; ---------------------------------------------------------------------------
; This is just for the actual text. For the level pointers, see: LevSel_Ptrs
; ---------------------------------------------------------------------------

LevelMenuText:
	charset ' ', $FF
	charset '0','9',$00
	charset '$', $0A
	charset '-', $0B
	charset '=', $0C
	charset '>', $0D
;	charset '>', $0E ; there are two identical right arrows in the font for some reason
	charset 'Y','Z',$0F ; Y and Z come before A-X
	charset 'A','X',$11

		dc.b "GREEN HILL ZONE  STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
	if Revision=0
		; old level order
		dc.b "LABYRINTH ZONE   STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "MARBLE ZONE      STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "STAR LIGHT ZONE  STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "SPRING YARD ZONE STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
	else
		; correct level order
		dc.b "MARBLE ZONE      STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "SPRING YARD ZONE STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "LABYRINTH ZONE   STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "STAR LIGHT ZONE  STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
	endif
		dc.b "SCRAP BRAIN ZONE STAGE 1"
		dc.b "                 STAGE 2"
		dc.b "                 STAGE 3"
		dc.b "FINAL ZONE              "
		dc.b "SPECIAL STAGE           "
		dc.b "SOUND SELECT            "
		even

	if MOMPASS=1
		if *-(levsel_line_count*levsel_line_length)<>LevelMenuText
			warning "LevelMenuText does not match expected line count/length."
		endif
		if (LevSel_PtrsEnd-LevSel_Ptrs)/2<>levsel_line_count
			warning "LevSel_Ptrs does not match expected line count."
		endif
	endif

	charset	; reset charset to default
	even

; ===========================================================================
; ---------------------------------------------------------------------------
; Music playlist for the start of a level. Note that restarting the music
; after invincibility has worn off is controlled in MusicList2 (part of
; Sonic's object). Bosses have the post-defeat music hardcoded.
; ---------------------------------------------------------------------------

MusicList:
		dc.b bgm_GHZ		; GHZ
		dc.b bgm_LZ		; LZ
		dc.b bgm_MZ		; MZ
		dc.b bgm_SLZ		; SLZ
		dc.b bgm_SYZ		; SYZ
		dc.b bgm_SBZ		; SBZ
		zonewarning MusicList,1
		dc.b bgm_FZ		; Ending
		even

