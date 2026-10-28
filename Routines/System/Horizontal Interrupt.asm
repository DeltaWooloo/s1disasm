HBlank:
		disable_ints					; disable interrupts (VBlank in this context)
		tst.w	(f_hblank_pal).w			; is palette set to change?
		beq.s	.nochg					; if not, branch
		move.w	#0,(f_hblank_pal).w			; clear palette change flag

		movem.l	a0-a1,-(sp)				; backup a0 and a1 registers
		lea	(vdp_data_port).l,a1			; load VDP data port to a1
		lea	(v_palette_water).w,a0			; get water palette from RAM
		move.l	#$C0000000,4(a1)			; set VDP to CRAM write
		rept (4*$10)/2					; overwrite full palette (4 rows, 2 colors per move)
			move.l	(a0)+,(a1)			; move water palette to CRAM
		endr						; repeat at assembly time
		move.w	#vreg_hintrate|223,4(a1)			; reset horizontal interrupt counter
		movem.l	(sp)+,a0-a1				; restore a0 and a1

		tst.b	(f_doupdatesinhblank).w			; was frame update delayed by water surface being near the top of the screen?
		bne.s	.delayed_transfer			; if yes, resume transfer now

.nochg:
		rte						; return from horizontal interrupt and resume normal operation
; ===========================================================================

; loc_119E:
.delayed_transfer:
		clr.b	(f_doupdatesinhblank).w			; clear delayed updates flag
		movem.l	d0-a6,-(sp)				; backup all registers except stack pointer (a7)
		bsr.w	VBlank_UpdateScreen			; do all the screen updates that were skipped during VBlank now
		jsr	(UpdateMusic).l				; update the sound driver
		movem.l	(sp)+,d0-a6				; restore registers
		rte						; return from horizontal interrupt and resume normal operation
; End of function HBlank


