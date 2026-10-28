DACDriverLoad:
		nop						; delay
		stopZ80						; request Z80 stop on
		deassertZ80Reset				; request Z80 reset off
		lea	(DACDriver).l,a0			; load compressed DAC driver address as source
		lea	(z80_ram).l,a1				; set Z80 RAM address as target
		bsr.w	KosDec					; decompress the DAC driver into Z80 RAM
		assertZ80Reset					; request Z80 reset on
		nop						; delay (while the Z80 resets)
		nop						; ''
		nop						; ''
		nop						; ''
		deassertZ80Reset				; request Z80 reset off
		startZ80					; request Z80 stop off
		rts						; return
; End of function DACDriverLoad

; ===========================================================================
; >>> Subroutines to queue sound commands to be executed by the sound driver during VBlank
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 1, often used for BGM
; 
; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; PlaySound:
QueueSound1:
		move.b	d0,(v_snddriver_ram.v_soundqueue0).w
		rts
; End of function QueueSound1

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 2, often used for SFX
; 
; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; PlaySound_Special:
QueueSound2:
		move.b	d0,(v_snddriver_ram.v_soundqueue1).w
		rts
; End of function QueueSound2

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	queue a sound into buffer 3, unused and broken.
; Enabling "FixBugs" will make this usable.
; 
; input:
;	d0 = track to play
; ---------------------------------------------------------------------------

; PlaySound_Unused:
QueueSound3:
		move.b	d0,(v_snddriver_ram.v_soundqueue2).w
		rts
; End of function QueueSound3
