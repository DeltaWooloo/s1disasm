; ---------------------------------------------------------------------------
; Palette index
; ---------------------------------------------------------------------------

makePalEntry:	macro paletteLabel,paletteRAMaddress,{INTLABEL}
__LABEL__:	label	(*-Pal_Index)/8
		dc.l paletteLabel
		dc.w paletteRAMaddress,(paletteLabel_end-paletteLabel)/4-1
		endm
; ---------------------------------------------------------------------------

Pal_Index:

; Id			Palette label,		RAM location
; NOTE: Palette size is calculated dynamically using an end marker made by bincludeEndMarker
palid_SegaBG:		makePalEntry	Pal_SegaBG, 		v_palette_line_1
palid_Title:		makePalEntry	Pal_Title,		v_palette_line_1
palid_LevelSel:		makePalEntry	Pal_LevelSel,		v_palette_line_1
palid_Sonic:		makePalEntry	Pal_Sonic,		v_palette_line_1

	Pal_Levels:
palid_GHZ:		makePalEntry	Pal_GHZ, 		v_palette_line_2
palid_LZ:		makePalEntry	Pal_LZ, 		v_palette_line_2
palid_MZ:		makePalEntry	Pal_MZ, 		v_palette_line_2
palid_SLZ:		makePalEntry	Pal_SLZ,		v_palette_line_2
palid_SYZ:		makePalEntry	Pal_SYZ,		v_palette_line_2
palid_SBZ1:		makePalEntry	Pal_SBZ1, 		v_palette_line_2
	zonewarning Pal_Levels,8

palid_Special:		makePalEntry	Pal_Special, 		v_palette_line_1
palid_LZWater:		makePalEntry	Pal_LZWater, 		v_palette_line_1
palid_SBZ3:		makePalEntry	Pal_SBZ3, 		v_palette_line_2
palid_SBZ3Water:	makePalEntry	Pal_SBZ3Water, 		v_palette_line_1
palid_SBZ2:		makePalEntry	Pal_SBZ2, 		v_palette_line_2
palid_LZSonWater:	makePalEntry	Pal_LZSonWater,		v_palette_line_1
palid_SBZ3SonWat:	makePalEntry	Pal_SBZ3SonWat,		v_palette_line_1
palid_SSResult:		makePalEntry	Pal_SSResult, 		v_palette_line_1
palid_Continue:		makePalEntry	Pal_Continue, 		v_palette_line_1
palid_Ending:		makePalEntry	Pal_Ending, 		v_palette_line_1
	even


; ===========================================================================
; ---------------------------------------------------------------------------
; Palette data bincludes
; ---------------------------------------------------------------------------

Pal_SegaBG:		bincludeEndMarker	"Game Modes/Sega Screen/palettes/Sega Background.bin"
Pal_Title:		bincludeEndMarker	"Game Modes/Title Screen/palettes/Title Screen.bin"
Pal_LevelSel:		bincludeEndMarker	"Game Modes/Title Screen/palettes/Level Select.bin"
Pal_Sonic:		bincludeEndMarker	"Objects/01 Sonic/palettes/Sonic.bin"
Pal_GHZ:		bincludeEndMarker	"Zones/Green Hill Zone/palettes/Green Hill Zone.bin"
Pal_LZ:			bincludeEndMarker	"Zones/Labyrinth Zone/palettes/Labyrinth Zone.bin"
Pal_LZWater:		bincludeEndMarker	"Zones/Labyrinth Zone/palettes/Labyrinth Zone Underwater.bin"
Pal_MZ:			bincludeEndMarker	"Zones/Marble Zone/palettes/Marble Zone.bin"
Pal_SLZ:		bincludeEndMarker	"Zones/Star Light Zone/palettes/Star Light Zone.bin"
Pal_SYZ:		bincludeEndMarker	"Zones/Spring Yard Zone/palettes/Spring Yard Zone.bin"
Pal_SBZ1:		bincludeEndMarker	"Zones/Scrap Brain Zone/palettes/SBZ Act 1.bin"
Pal_SBZ2:		bincludeEndMarker	"Zones/Scrap Brain Zone/palettes/SBZ Act 2.bin"
Pal_Special:		bincludeEndMarker	"Game Modes/Special Stage/palettes/Special Stage.bin"
Pal_SBZ3:		bincludeEndMarker	"Zones/Scrap Brain Zone/palettes/SBZ Act 3.bin"
Pal_SBZ3Water:		bincludeEndMarker	"Zones/Scrap Brain Zone/palettes/SBZ Act 3 Underwater.bin"
Pal_LZSonWater:		bincludeEndMarker	"Zones/Labyrinth Zone/palettes/Sonic - LZ Underwater.bin"
Pal_SBZ3SonWat:		bincludeEndMarker	"Zones/Scrap Brain Zone/palettes/Sonic - SBZ3 Underwater.bin"
Pal_SSResult:		bincludeEndMarker	"Game Modes/Special Stage/palettes/Special Stage Results.bin"
Pal_Continue:		bincludeEndMarker	"Game Modes/Special Stage/palettes/Special Stage Continue Bonus.bin"
Pal_Ending:		bincludeEndMarker	"Game Modes/Ending/palettes/Ending.bin"