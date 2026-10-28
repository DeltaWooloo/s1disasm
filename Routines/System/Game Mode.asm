GameProgram:
		tst.w	(vdp_control_port).l			; clear write-pending flag in VDP (prevents issues if 68k was reset while writing a command to VDP)
		btst	#6,(expansion_control).l		; has port C been initialized?
		beq.s	CheckSumCheck				; if not, branch
		cmpi.l	#'init',(v_init).w			; has checksum routine already run?
		beq.w	GameInit				; if yes, branch

CheckSumCheck:
	if SkipChecksumCheck=0
		movea.l	#EndOfHeader,a0				; start checking bytes after the header ($200)
		movea.l	#RomEndLoc,a1				; stop at end of ROM
		move.l	(a1),d0					; retrieve long of ROM end
		moveq	#0,d1					; clear d1
	.loop:	add.w	(a0)+,d1				; add next byte value of ROM word
		cmp.l	a0,d0					; has iterator reached end of ROM?
		bhs.s	.loop					; if not, loop until so

		movea.l	#Checksum,a1				; read the checksum
		cmp.w	(a1),d1					; compare calculated value with checksum in ROM header
		bne.w	CheckSumError				; if they don't match, a checksum error has occurred
	endif

CheckSumOk:
		lea	(v_crossresetram).w,a6			; load cross-reset RAM location
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_ram_end-v_crossresetram)/4-1,d6	; write to all of cross-reset RAM ($FE00-$FFFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		move.b	(console_version).l,d0			; get hardware information from console
		andi.b	#%11000000,d0				; filter to only overseas flag and PAL flag
		move.b	d0,(v_megadrive).w			; store region settings

		move.l	#'init',(v_init).w			; set flag so checksum won't run again

GameInit:
		lea	(v_ram_start).l,a6			; load start location of RAM
		moveq	#0,d7					; overwrite with 0
		move.w	#(v_crossresetram-v_ram_start_def)/4-1,d6 ; write to all of RAM except cross-reset RAM ($0000-$FDFF)
.clearRAM:	move.l	d7,(a6)+				; clear RAM
		dbf	d6,.clearRAM				; loop until done

		bsr.w	VDPSetupGame				; initialize (proper) VDP registers
		bsr.w	DACDriverLoad				; initialize Z80 DAC driver
		bsr.w	JoypadInit				; initialize controller ports
		move.b	#id_Sega,(v_gamemode).w			; set first Game Mode to Sega Screen

	if CheatsEnabled=1
		moveq	#1,d0					; enable all cheats by default
		move.b	d0,(f_levselcheat).w			; enable level select cheat
		move.b	d0,(f_slomocheat).w			; enable slow-motion cheat
		move.b	d0,(f_debugcheat).w			; enable debug mode cheat
		move.b	d0,(f_creditscheat).w			; enable hidden Japanese credits cheat
	endif

MainGameLoop:
		move.b	(v_gamemode).w,d0			; load Game Mode
		andi.w	#$1C,d0					; limit Game Mode value to $1C max (change to a maximum of 7C to add more game modes)
		jsr	GameModeArray(pc,d0.w)			; jump to apt location in ROM
		bra.s	MainGameLoop				; loop indefinitely

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:

gmptr:		macro gamemode,{INTLABEL}
__LABEL__:	label	*-GameModeArray
		bra.w	gamemode
		endm

id_Sega:	gmptr	GM_Sega					; Sega Screen ($00)
id_Title:	gmptr	GM_Title				; Title Screen ($04)
id_Demo:	gmptr	GM_Level				; Demo Mode ($08)
id_Level:	gmptr	GM_Level				; Normal Level ($0C)
id_Special:	gmptr	GM_Special				; Special Stage ($10)
id_Continue:	gmptr	GM_Continue				; Continue Screen ($14)
id_Ending:	gmptr	GM_Ending				; End of game sequence ($18)
id_Credits:	gmptr	GM_Credits				; Credits ($1C)

		rts						; redundant rts


