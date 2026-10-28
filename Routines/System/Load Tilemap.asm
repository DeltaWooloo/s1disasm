; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to copy a tile map from RAM to VRAM namespace

; input:
;	a1 = tile map address
;	d0 = VRAM address
;	d1 = width (cells)
;	d2 = height (cells)
; ---------------------------------------------------------------------------

TilemapToVRAM:
		lea	(vdp_data_port).l,a6			; load VDP data port address
		move.l	#$800000,d4				; prepare plane width size for VDP address advancing (row)

Tilemap_Line:
		move.l	d0,4(a6)				; set the VDP the VRAM write mode with address
		move.w	d1,d3					; load width of rectangle

Tilemap_Cell:
		move.w	(a1)+,(a6)				; copy tile map to VRAM plane space
		dbf	d3,Tilemap_Cell				; repeat for the entire width
		add.l	d4,d0					; advance VDP value address to the next row
		dbf	d2,Tilemap_Line				; repeat for the entire height
		rts						; return
; End of function TilemapToVRAM

