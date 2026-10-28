; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load main palettes into the fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.

; input:
; d0 = index number for palette
; ---------------------------------------------------------------------------

PalLoad_Fade:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		adda.w	#v_palette_fading-v_palette,a3		; load to palette fade-in buffer instead of active palette buffer (+$80)
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade

; ---------------------------------------------------------------------------
; Subroutine to directly load main palettes to the active palette.
; Same as PalLoad_Fade, but without adding $80.
; ---------------------------------------------------------------------------

PalLoad:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load underwater palettes into the water fading buffer.
; These get displayed once PaletteFadeIn/PaletteWhiteIn is called.
; ---------------------------------------------------------------------------

PalLoad_Fade_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water,a3		; load to (water) palette fade-in buffer instead of active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Fade_Water

; ---------------------------------------------------------------------------
; Subroutine to directly load underwater palettes to the active palette.
; Same as PalLoad_Fade_Water, but writing $80 before it.
; ---------------------------------------------------------------------------

PalLoad_Water:
		lea	(Pal_Index).l,a1			; get palette pointers
		lsl.w	#3,d0					; multiply input ID by 8 (size of one palette index entry)
		adda.w	d0,a1					; add to palette index pointer to get relevant palette entry
		movea.l	(a1)+,a2				; get palette data address
		movea.w	(a1)+,a3				; get target RAM address
		suba.w	#v_palette-v_palette_water_fading,a3	; load to active (water) palette buffer instead of main active palette buffer
		move.w	(a1)+,d7				; get length of palette data

.loop:
		move.l	(a2)+,(a3)+				; move two colors from palette data to palette buffer RAM
		dbf	d7,.loop				; loop until all colors are loaded
		rts						; return
; End of function PalLoad_Water

; ===========================================================================
; >>> Palette pointers and palette binary includes
	include	"Routines/Palette Index.asm"


